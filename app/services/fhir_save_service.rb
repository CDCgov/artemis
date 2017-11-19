class FhirSaveService < ApplicationService
  def call!(report_id, method = :nbs)
    report = Report.find(report_id)
    report.send(method).map do |record|
      Rails.logger.debug "Record ID: #{record.id}"
      record.tap { |r| r.save_to_fhir client }
    end
  end

  private

  def client
    @client ||= FHIR::Client.new(Rails.application.config.fhir['server_url'])
  end
end
