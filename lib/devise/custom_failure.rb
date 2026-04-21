class CustomFailure < Devise::FailureApp
  def redirect_url
    case warden_message
    when :timeout || :reauthenticate
      session_expired_path(reason: warden_message)
    else
      super
    end
  end
end
