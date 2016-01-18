class Users::PasswordsController < Devise::PasswordsController
  respond_to :js, :html

  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  def create
    super
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  # protected

  def after_sending_reset_password_instructions_path_for(resource_name)
    flash[:notice] = t('devise.passwords.send_instructions')
    root_path
  end
end
