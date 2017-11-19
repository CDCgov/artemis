# This class represents the base class for newborn records. Currently, this will
# pull directly from the CSV file located in the <APP_ROOT>/data/ folder, but in
# the future, might be adapted to accomodate a connection to a database.
require 'csv'
require 'fhir_client'

# rubocop:disable Metrics/ClassLength
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
    create_patient.tap do |patient|
      patient.id = self[:kit]
    end
  end

  def mother_info(patient)
    create_mother.tap do |mother|
      mother.patient = FHIR::Reference.new(reference: "Patient/#{patient.id}")
      mother.id = SecureRandom.uuid
    end
  end

  def add_mother_to_patient(mother, patient)
    mother_ref = FHIR::Reference.new(reference: "RelatedPerson/#{mother.id}")
    link = FHIR::Patient::Link.new
    link.other = mother_ref
    link.type = 'refer'
    patient.link.append link
  end

  def birth_length_observation(patient)
    observation = observation_with_loinc '8305-5', self[:birth_length], 'cm'
    reference = FHIR::Reference.new
    reference.reference = "Patient/#{patient.id}"
    observation.subject = reference
    observation
  end

  def birth_weight_observation(patient)
    observation = observation_with_loinc '56056-5', self[:birth_weight], 'g'
    reference = FHIR::Reference.new
    reference.reference = "Patient/#{patient.id}"
    observation.subject = reference
    observation
  end

  def save_to_fhir client
    begin
      patient = to_fhir

      client.begin_transaction
      client.add_transaction_request('POST', nil, patient)
      client.add_transaction_request('POST', nil, mother_info(patient))
      client.add_transaction_request('POST', nil, birth_weight_observation(patient))
      client.add_transaction_request('POST', nil, birth_length_observation(patient))
      client.end_transaction
    rescue StandardError => e
      Rails.logger.debug e.message
      client
    end
  end

  private

  def create_mother
    FHIR::RelatedPerson.new(
      name: { given: self[:mothers_first_name], family: self[:mothers_last_name] },
      birthDate: self[:mothers_birthdate]
    )
  end

  def create_patient
    FHIR::Patient.new(
      identifier: { use: 'official', value: self[:id] },
      name: { given: self[:first_name], family: self[:last_name] },
      birthDate: self[:birthdate],
      gender: map_gender(self[:sex]),
      multipleBirthInteger: self[:multiple_birth]
    )
  end

  def observation_with_loinc(code, value, unit)
    FHIR::Observation.new.tap do |observation|
      observation.code = FHIR::CodeableConcept.new
      observation.code.coding = [create_coding(code)]
      observation.valueQuantity = create_quantity(value, unit)
    end
  end

  def create_coding(code)
    FHIR::Coding.new.tap do |coding|
      coding.system = 'http://loinc.org'
      coding.code = code
    end
  end

  def create_quantity(value, unit)
    FHIR::Quantity.new.tap do |quantity|
      quantity.value = value
      quantity.unit = unit
    end
  end

  def map_gender(gender_letter)
    lookup = { 'M' => 'male', 'F' => 'female' }
    lookup.default = 'unknown'
    lookup[gender_letter]
  end
end
