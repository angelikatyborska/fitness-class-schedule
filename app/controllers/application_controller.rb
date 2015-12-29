class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  decent_configuration do
    strategy DecentExposure::StrongParametersStrategy
  end

  expose(:rooms)
  expose(:trainers)
  expose(:week) { params[:week].nil? ? Time.zone.now : Time.parse(params[:week])}
end
