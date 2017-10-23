class ReportsController < ApplicationController
  before_action :set_report, only: %i[show edit update destroy]

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

  # POST /reports
  # POST /reports.json
  def create
    @report = BatchCompareService.call

    if @report
      redirect_to @report, notice: 'Report was successfully created.'
    else
      redirect_to :back
    end
  end

  private

  def set_report
    @report = Report.find(params[:id])
  end
end
