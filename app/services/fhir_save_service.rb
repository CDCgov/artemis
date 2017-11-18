class FhirSaveService < ApplicationService
  def call!(records, result)
    # TODO: plug into FHIR logic
    raise StandardError, 'kaboom!' unless result
    Rails.logger.info 'Attempting to save records'
    Rails.logger.info records
    true
  end
end
