class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # FIXME: temporary endpoint
  def report
    render json: BatchCompareService.call!
  rescue StandardError => exception
    render json: { error: exception.message }
  end
end
