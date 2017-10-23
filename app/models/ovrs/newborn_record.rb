# This class represents the data model interface with the Office of Vital
# Records and Statistics source. Currently, this will pull directly from the CSV
# file located in the <APP_ROOT>/data/ folder, but in the future, might be
# adapted to accomodate a connection to the OVRS database.
require 'csv'

# rubocop:disable Metrics/LineLength
class OVRS::NewbornRecord < ActiveHash::Base
  # We want to make the initializer private, since we can't yet create data
  private_class_method :new

  class << self
    def reload
      self.data = source
      true
    end

    private

    def csv_file
      Rails.root.join('data', 'OVRS_data.csv')
    end

    def extract_date(fields = [], hash = {})
      Date.new(*fields.map { |field| hash.delete(field) }) rescue nil # rubocop:disable Style/RescueModifier
    end

    def format_headers(hash = {}) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
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
        h[:state_file_number]   = h.delete :statefilenumber

        # Cast dates
        h[:birthdate]           = extract_date %i[birthccyy birthmm birthdd], h
        h[:mothers_birthdate]   = extract_date %i[mombirthccyy mombirthmm mombirthdd], h

        # NOTE: ID assignment assumes that there are no duplicate Kit ID_numbers
        h[:id]                  = h[:kit] || SecureRandom.uuid
      end
    end

    def source
      Rails.cache.fetch("ovrs/#{File.mtime(csv_file).to_i}") do
        CSV.table(csv_file).map { |row| format_headers(row.to_hash) }
      end
    end
  end

  # Set internal data for ActiveHash use
  self.data = source
end
