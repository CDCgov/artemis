class ReportsController < ApplicationController
  before_action :set_report, only: %i[show fhir]

  # GET /reports
  # GET /reports.json
  def index
    @reports = Report.order(created_at: :desc).all
  end

  # GET /reports/1
  # GET /reports/1.json
  def show; end

  # GET /reports/latest
  def latest
    redirect_to Report.last
  end

  # POST /reports/1/fhir
  def fhir
    if FhirSaveService.call @report.id
      redirect_back fallback_location: root_path, notice: 'Successfully saved to FHIR!'
    else
      redirect_back fallback_location: root_path, alert: 'Could not save to FHIR.'
    end
  end

  # GET /reports/new
  def new
    @report = Report.new
  end

  # POST /reports
  # POST /reports.json
  def create
    # TODO: error-handling
    ProcessCsvUploadService.call! nbs:  report_params[:nbs_file].read,
                                  ovrs: report_params[:ovrs_file].read

    @report = BatchCompareService.call

    if @report.save
      redirect_to @report, notice: 'Report was successfully created.'
    else
      redirect_to new_report_path, alert: 'Could not generate a report.'
    end
  end

  private

  def report_params
    params.permit(:nbs_file, :ovrs_file)
  end

  def set_report
    @report = Report.find(params[:id] || params[:report_id])
  end
end
