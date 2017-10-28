# Newborn records from the Newborn Screening Data (NBS) database
class NBS::NewbornRecord < CsvRecord
  class << self
    private

    def format_fields(hash = {})
      hash.tap do |h|
        # Re-map headers
        h[:first_name]          = h.delete :babys_first_name
        h[:kit]                 = h.delete :name
        h[:last_name]           = h.delete :babys_last_name
        h[:mothers_first_name]  = nil
        h[:sex]                 = h.delete :babys_sex

        # Cast dates
        h[:birthdate]           = format_date h[:birthdate]
        h[:mothers_birthdate]   = format_date h[:mothers_birthdate]

        # NOTE: ID assignment assumes that there are no duplicate Kit ID_numbers
        h[:id]                  = h[:kit] || SecureRandom.uuid
      end
    end
  end

  # Set internal data for ActiveHash use
  self.data = source
end
