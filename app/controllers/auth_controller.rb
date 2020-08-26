class AuthController < ApplicationController
  class AuthorizationError < StandardError; end

  def failure
    # redirect to consents page if it was an applicant failing to login at his bank
    #
    redirect_to citizens_consent_path(auth_failure: true)
  end
end
