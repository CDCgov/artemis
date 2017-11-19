class FhirSaveService < ApplicationService
  def call!(records)
    Rails.logger.info "FHIR URL: #{config.fhir.server_url}"
    client = FHIR::Client.new(config.fhir.server_url)
    records.each do |rec|
      rec.save_to_fhir client
    end
    true
  end
end
