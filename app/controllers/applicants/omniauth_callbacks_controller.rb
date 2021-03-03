# This controller handles the user's return from the True Layer Oauth2 authentication
# Note that you may need to restart the server to apply changes to this file.
module Applicants
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    class MissingApplicantError < StandardError; end
    before_action :authenticate_applicant!, only: [:true_layer]
    skip_back_history_for :true_layer, :failure

    def true_layer
      unless applicant
        set_flash_message(:error, :failure, kind: 'TrueLayer', reason: 'Unable to find matching application')
        Sentry.capture_exception(MissingApplicantError.new('Unable to find applicant on return from TrueLayer'))
        redirect_to citizens_consent_path
        return
      end

      store_tokens
      redirect_to citizens_gather_transactions_path
    end

    private

    def store_tokens
      applicant.store_true_layer_token(token: token, expires: token_expires_at)
    end

    def token
      credentials.token
    end

    def token_expires_at
      expires_at = credentials.expires_at
      case expires_at
      when Integer
        Time.zone.at(expires_at)
      when String
        Time.zone.parse(expires_at)
      else
        Rails.logger.info 'Unable to determine expiry'
        nil
      end
    end

    def credentials
      @credentials ||= request.env['omniauth.auth'].credentials
    end

    def applicant
      @applicant ||= current_applicant
    end
  end
end
