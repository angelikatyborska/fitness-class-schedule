class Users::PasswordsController < Devise::PasswordsController
  respond_to :js, :html

  protected

  def is_flashing_format?
    super || request_format == :js
  end
end
