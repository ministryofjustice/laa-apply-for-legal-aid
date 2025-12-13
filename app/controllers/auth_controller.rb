class AuthController < ApplicationController
  include Devise::Controllers::Rememberable

  def failure
    # redirect to consents page if it was an applicant failing to login at his bank
    if during_citizen_bank_login?
      redirect_to citizens_consent_path(auth_failure: true)
    else
      redirect_to error_path(:access_denied)
    end
  end

private

  def during_citizen_bank_login?
    return false if origin.blank?

    URI(origin).path == "/citizens/banks"
  end

  def origin
    @origin ||= failure_params[:origin]
  end

  def failure_params
    params.permit(:message, :origin, :strategy)
  end
end
