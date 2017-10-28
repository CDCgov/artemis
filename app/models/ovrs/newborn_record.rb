# Newborn records from the Office of Vital Records and Statistics (OVRS)

# rubocop:disable Metrics/LineLength
class OVRS::NewbornRecord < CsvRecord
  class << self
    private

    def extract_date(fields = [], hash = {})
      Date.new(*fields.map { |field| hash.delete(field) }) rescue nil # rubocop:disable Style/RescueModifier
    end

    def format_fields(hash = {}) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      hash.tap do |h|
        # Re-map headers
        h[:birth_length]        = h.delete :childlengthcm
        h[:birth_weight]        = h.delete :birthweightgrams
        h[:first_name]          = h.delete :childfirst
        h[:kit]                 = h.delete :newbornscreeningnumber
        h[:last_name]           = h.delete :childlast
        h[:mothers_first_name]  = h.delete :momfirst
        h[:mothers_last_name]   = h.delete :momlast
        h[:multiple_birth]      = h.delete :plurality
        h[:sex]                 = h.delete :gender

        # Remove unneeded fields
        h.delete :statefilenumber

        # Cast dates
        h[:birthdate]           = extract_date %i[birthccyy birthmm birthdd], h
        h[:mothers_birthdate]   = extract_date %i[mombirthccyy mombirthmm mombirthdd], h

        # NOTE: ID assignment assumes that there are no duplicate Kit ID_numbers
        h[:id]                  = h[:kit] || SecureRandom.uuid
      end
    end
  end

  # Set internal data for ActiveHash use
  self.data = source
end
