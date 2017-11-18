class MainController < ApplicationController
  def index; end

  # POST /fhir
  def fhir
    @records = record_params.map { |record| JSON.parse(record) }

    if FhirSaveService.call @records, [true, false].sample
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
