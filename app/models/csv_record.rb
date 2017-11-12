# This class represents the base class for newborn records. Currently, this will
# pull directly from the CSV file located in the <APP_ROOT>/data/ folder, but in
# the future, might be adapted to accomodate a connection to a database.
require 'csv'
require 'fhir_client'
require 'SecureRandom'

class CsvRecord < ActiveHash::Base
  FIELD_HIERARCHY = %i[
    kit
    birthdate
    mothers_birthdate
    mothers_last_name
    mothers_first_name
    sex
    last_name
    first_name
    multiple_birth
    birth_weight
    birth_length
  ].freeze

  class << self
    def collection_cache_key
      [prefix, File.mtime(csv_file).to_i].join '/'
    end

    def find_or_match(id, other_model)
      find_by(id: id) || match(other_model.find_by(id: id))
    end

    def match(record, matches = all, fields = FIELD_HIERARCHY) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/LineLength
      # Cast to object if hash passed
      record = new record if record.is_a? Hash

      # Base case
      return (matches.length == 1 ? matches.first : nil) if fields.empty?

      # Recursive case
      field, *fields = fields
      value = record.send(field)

      # Early return if value is nil
      return match(record, matches, fields) unless value

      # Reduce values
      # NOTE: ActiveHash cannot chain #where, unfortunately, so we cast to Array
      maybe_matches = matches.to_a.select { |other| other.send(field) == value }
      return match(record, matches, fields) if maybe_matches.empty?

      # Early return if one match found
      return maybe_matches.first if maybe_matches.length == 1

      match(record, maybe_matches, fields)
    end

    def load(data)
      Rails.cache.delete collection_cache_key
      self.data = CSV.parse(data, headers: true,
                                  converters: :numeric,
                                  header_converters: :symbol).map do |row|
        format_fields(row.to_hash)
      end
      true
    end

    def prefix
      to_s.split('::').first
    end

    def reload
      Rails.cache.delete collection_cache_key
      self.data = source
      true
    end

    private

    def csv_file
      Rails.root.join 'data', "#{prefix}_data.csv"
    end

    def format_date(string)
      Date.strptime(string, '%m/%d/%Y') rescue nil # rubocop:disable Style/RescueModifier, Metrics/LineLength
    end

    def format_fields(_hash = {})
      raise NotImplementedError
    end

    def source
      Rails.cache.fetch(collection_cache_key) do
        CSV.table(csv_file).map { |row| format_fields(row.to_hash) }
      end
    end
  end

  # Instance methods
  def match(others, *args)
    self.class.match(self, others, *args)
  end

  def to_fhir
    patient = FHIR::Patient.new(
      identifier: { use: 'official', value: self[:id] },
      name: { given: self[:first_name], family: self[:last_name] },
      birthDate: self[:birthdate],
      gender: map_gender(self[:sex]),
      multipleBirthInteger: self[:multiple_birth]
    )
    patient.id = SecureRandom.uuid
    mother = mother_info patient
    mother_ref = FHIR::Reference.new(reference: "RelatedPerson/#{mother.id}")
    link = FHIR::Patient::Link.new
    link.other = mother_ref
    link.type = 'refer'
    patient.link.append link

    patient
  end

  def mother_info(patient)
    mother = FHIR::RelatedPerson.new(
      name: { given: self[:mothers_first_name], family: self[:mothers_last_name] },
      birthDate: self[:mothers_birthdate]
    )
    mother.patient = FHIR::Reference.new(reference: "Patient/#{patient.id}")
    mother.id = SecureRandom.uuid
    mother
  end

  def birth_length(patient)
    observation = observation_with_loinc '8305-5', self[:birth_length], 'cm'
    reference = FHIR::Reference.new
    reference.reference = "Patient/#{patient.id}"
    observation.subject = reference
    observation
  end

  def birth_weight(patient)
    observation = observation_with_loinc '56056-5', self[:birth_weight], 'g'
    reference = FHIR::Reference.new
    reference.reference = "Patient/#{patient.id}"
    observation.subject = reference
    observation
  end

  private

  def observation_with_loinc(code, value, unit)
    observation = FHIR::Observation.new
    coding = FHIR::Coding.new
    coding.system = 'http://loinc.org'
    coding.code = code
    observation.code = FHIR::CodeableConcept.new
    observation.code.coding = [coding]
    quantity = FHIR::Quantity.new
    quantity.value = value
    quantity.unit = unit
    observation.valueQuantity = quantity
    observation
  end

  def map_gender(gender_letter)
    lookup = { 'M' => 'male', 'F' => 'female' }
    lookup.default = 'unknown'
    lookup[gender_letter]
  end
end
