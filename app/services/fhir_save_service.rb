class FhirSaveService < ApplicationService
  def call!(records)
    Rails.logger.info "FHIR URL: #{ENV['FHIR_URL']}"
    client = FHIR::Client.new(ENV['FHIR_URL'])
    records.each do |rec|
      Rails.logger.debug "Record ID: #{rec['attributes']['id']}"
      patient = NBS::NewbornRecord.find(rec['attributes']['id'])
      patient.save_to_fhir client
    end
    true
  end
end
