# This class represents the base class for newborn records. Currently, this will
# pull directly from the CSV file located in the <APP_ROOT>/data/ folder, but in
# the future, might be adapted to accomodate a connection to a database.
require 'csv'

class CsvRecord < ActiveHash::Base
  class << self
    def collection_cache_key
      [prefix, File.mtime(csv_file).to_i].join '/'
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

    def prefix
      to_s.split('::').first
    end

    def source
      Rails.cache.fetch(collection_cache_key) do
        CSV.table(csv_file).map { |row| format_fields(row.to_hash) }
      end
    end
  end
end
