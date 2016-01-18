class CustomFailure < Devise::FailureApp

  def respond
    if request.xhr? && warden_message == :unconfirmed
      flash[:alert] = I18n.t('devise.failure.unconfirmed')
    end

    if http_auth?
      http_auth
    elsif warden_options[:recall]
      recall
    else
      redirect
    end
  end

end