class CustomFailure < Devise::FailureApp
  def redirect_url
    if warden_message == :timeout
      session_expired_path # (reason: :timeout)
    elsif warden_message == :reauthenticate
      session_expired_path # (reason: :reauthenticate)
    else
      super
    end
  end
end
