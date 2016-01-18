class Users::RegistrationsController < Devise::RegistrationsController
  clear_respond_to
  respond_to :js, :html

  def create
    super
    resource
  end

  def failure
    warden.custom_failure!

    self.resource
    flash.now[:alert] = I18n.t('devise.failure.invalid', authentication_keys: 'email')
    render :new
  end

  def auth_options
    {:scope => resource_name, :recall => "#{controller_path}#failure"}
  end

  def is_flashing_format?
    super || request_format == :js
  end
end
