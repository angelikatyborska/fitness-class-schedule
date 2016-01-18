class Users::RegistrationsController < Devise::RegistrationsController
  clear_respond_to
  respond_to :js, :html

  protected

  def is_flashing_format?
    super || request_format == :js
  end
end
