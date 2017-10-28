# This class represents the data model interface with the Newborn Screening Data
# source. Currently, this will pull directly from the CSV file located in the
# <APP_ROOT>/data/ folder, but in the future, might be adapted to accomodate
# a connection to the NBS database.
require 'csv'

class NBS::NewbornRecord < ActiveHash::Base
  # We want to make the initializer private, since we can't yet create data
  private_class_method :new

  class << self
    def collection_cache_key
      "nbs/#{File.mtime(csv_file).to_i}"
    end

    def reload
      Rails.cache.delete collection_cache_key
      self.data = source
      true
    end

    private

    def csv_file
      Rails.root.join('data', 'NBS_data.csv')
    end

    def format_date(string)
      Date.strptime(string, '%m/%d/%Y') rescue nil # rubocop:disable Style/RescueModifier, Metrics/LineLength
    end

    def format_headers(hash = {})
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

    def source
      Rails.cache.fetch(collection_cache_key) do
        CSV.table(csv_file).map { |row| format_headers(row.to_hash) }
      end
    end
  end

  # Set internal data for ActiveHash use
  self.data = source
end
