# This controller handles the user's return from the True Layer Oauth2 authentication
# Note that you may need to restart the server to apply changes to this file.
module Applicants
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def true_layer
      if applicant
        applicant.update!(
          true_layer_token: token,
          true_layer_token_expires_at: token_expires_at
        )
        scope = Devise::Mapping.find_scope!(applicant)
        sign_in(scope, applicant, event: :authentication)
        set_flash_message(:notice, :success, kind: 'TrueLayer')
        redirect_to citizens_accounts_path
      else
        set_flash_message(:error, :failure, kind: 'TrueLayer', reason: identification_tool.error)
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
      case credentials.expires_at
      when Integer
        Time.at(credentials.expires_at)
      when String
        Time.parse(credentials.expires_at)
      else
        Rails.logger.info 'Unable to determine expiry'
        nil
      end
    end

    def identification_tool
      @identification_tool ||= TrueLayer::IdentifyApplicant.new(token)
    end

    def applicant
      @applicant ||= identification_tool.applicant
    end
  end
end
