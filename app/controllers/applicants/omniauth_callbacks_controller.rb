# This controller handles the user's return from the True Layer Oauth2 authentication
# Note that you may need to restart the server to apply changes to this file.
module Applicants
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    before_action :authenticate_applicant!, only: [:true_layer]

    def true_layer
      if applicant
        applicant.update!(
          true_layer_token: token,
          true_layer_token_expires_at: token_expires_at
        )
        set_flash_message(:notice, :success, kind: 'TrueLayer')
        redirect_to citizens_accounts_path
      else
        set_flash_message(:error, :failure, kind: 'TrueLayer', reason: 'Unable to find matching application')
        redirect_to root_path
      end
    end

    def failure
      redirect_to root_path
    end

    private

    def credentials
      @credentials ||= request.env['omniauth.auth'].credentials
    end

    def token
      credentials.token
    end

    def token_expires_at
      expires_at = credentials.expires_at
      case expires_at
      when Integer
        Time.at(expires_at)
      when String
        Time.parse(expires_at)
      else
        Rails.logger.info 'Unable to determine expiry'
        nil
      end
    end

    def applicant
      @applicant ||= current_applicant
    end
  end
end
