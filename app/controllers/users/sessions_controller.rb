class Users::SessionsController < Devise::SessionsController
  clear_respond_to
  respond_to :js

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

  # overwrite to respond with destroy.js.erb (default rails behavior) instead of 204 no content (default devise behavior)
  def respond_to_on_destroy
  end
end
