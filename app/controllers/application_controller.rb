class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  alias_method :devise_current_user, :current_user

  decent_configuration do
    strategy DecentExposure::StrongParametersStrategy
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |user|
      user.permit(:first_name, :last_name, :email, :password, :password_confirmation, :remember_me)
    end

    devise_parameter_sanitizer.for(:sign_in) do |user|
      user.permit(:email, :password, :remember_me)
    end

    devise_parameter_sanitizer.for(:account_update) do |user|
      user.permit(:password, :password_confirmation, :current_password)
    end
  end
end
