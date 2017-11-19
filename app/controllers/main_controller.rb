class MainController < ApplicationController
  def index; end

  # POST /fhir
  def fhir
    Rails.logger.info "FHIR URL: #{ENV['FHIR_URL']}"
    @records = record_params.map { |record| JSON.parse(record) }

    if FhirSaveService.call @records
      redirect_back fallback_location: root_path, notice: 'Successfully saved to FHIR!'
    else
      redirect_back fallback_location: root_path, alert: 'Could not save to FHIR.'
    end
  end

  private

  def record_params
    params.require(:records)
  end
end
