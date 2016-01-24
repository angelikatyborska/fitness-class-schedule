class Users::SessionsController < Devise::SessionsController
  clear_respond_to
  respond_to :js, :html

  def failure
    warden.custom_failure!

    flash.now[:alert] = I18n.t('devise.failure.invalid', authentication_keys: 'email')
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    render :new
  end

  protected

  def auth_options
    {:scope => resource_name, :recall => "#{controller_path}#failure"}
  end

  def is_flashing_format?
    super || request_format == :js
  end
end
