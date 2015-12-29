class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  expose(:rooms)
  expose(:week) { params[:week].nil? ? Time.zone.now : Time.parse(params[:week])}
end
