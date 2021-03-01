class AuthController < ApplicationController
  include Devise::Controllers::Rememberable

  class AuthorizationError < StandardError; end

  def failure
    # redirect to consents page if it was an applicant failing to login at his bank
    #
    Sentry.capture_message("Omniauth failure #{params.to_unsafe_hash.inspect}")
    if auth_error_during_bank_login?
      begin
        raise AuthorizationError, "Redirecting to access denied page - unexpected origin: '#{origin}'"
      rescue StandardError => e
        Sentry.capture_exception(e)
      end
      redirect_to error_path(:access_denied)
    else
      redirect_to citizens_consent_path(auth_failure: true)
    end
  end

  private

  def origin
    @origin ||= params[:origin]
  end

  def auth_error_during_bank_login?
    return true if origin.nil?

    URI(origin).path != '/citizens/banks'
  end
end
