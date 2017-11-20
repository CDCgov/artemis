class ReportsController < ApplicationController
  before_action :set_report, only: %i[show edit update destroy]

  # GET /reports
  # GET /reports.json
  def index
    @reports = Report.order(created_at: :desc).all
  end

  # GET /reports/1
  # GET /reports/1.json
  def show
    @nbs = NBS::NewbornRecord.all.map(&:to_json)
  end

  # GET /reports/latest
  def latest
    redirect_to Report.last
  end

  # GET /reports/new
  def new
    @report = Report.new
  end

  # POST /reports
  # POST /reports.json
  def create
    begin

      ProcessCsvUploadService.call! nbs:  report_params[:nbs_file].read,
                                  ovrs: report_params[:ovrs_file].read
    rescue => ex
      logger.error ex.message
      redirect_to new_report_path, alert: 'Failed to load files, csv format was not correct (csv headers may not be correct)'
      return
    end
    
    begin

      @report = BatchCompareService.call

    rescue => ex
      logger.error ex.message
      redirect_to new_report_path, alert: 'Failed to compare records, an error occured'
      return
    end

    begin
      if @report.save

         redirect_to @report, notice: 'Report was successfully created.'
      
      else
        redirect_to new_report_path, alert: 'Could not generate a report.'
      end
    rescue => ex
      logger.error ex.message
      redirect_to new_report_path, alert: 'Failed to save report, an error occured'    
    end

  end

  private

  def report_params
    params.permit(:nbs_file, :ovrs_file)
  end

  def set_report
    @report = Report.find(params[:id])
  end
end
