class AuthController < ApplicationController
  class AuthorizationError < StandardError; end

  def failure
    # redirect to consents page if it was an applicant failing to login at his bank
    #
    if auth_error_during_bank_login?
      redirect_to citizens_consent_path(auth_failure: true)
    else
      begin
        raise AuthorizationError, 'Redirecting to access denied page'
      rescue StandardError => e
        Raven.capture_exception(e)
      end
      redirect_to error_path(:access_denied)
    end
  end


  def auth_error_during_bank_login?
    params&.fetch(:origin).match?(/citizens\/banks$/)
  end
end
