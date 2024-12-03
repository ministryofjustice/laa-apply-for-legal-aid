class AuthController < ApplicationController
  include Devise::Controllers::Rememberable

  def failure
    # redirect to consents page if it was an applicant failing to login at his bank
    #
    if auth_error_during_bank_login?
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

    URI(origin).path != "/citizens/banks"
  end
end
