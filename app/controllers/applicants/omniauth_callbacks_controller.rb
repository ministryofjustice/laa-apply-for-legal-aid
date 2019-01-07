# This controller handles the user's return from the True Layer Oauth2 authentication
# Note that you may need to restart the server to apply changes to this file.
module Applicants
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    before_action :authenticate_applicant!, only: [:true_layer]

    def true_layer
      unless applicant
        set_flash_message(:error, :failure, kind: 'TrueLayer', reason: 'Unable to find matching application')
        redirect_to citizens_consent_path
        return
      end

      import_bank_data
      redirect_to citizens_accounts_path
    end

    def failure
      set_flash_message(:error, :failure, kind: 'TrueLayer', reason: 'Process cancelled')
      redirect_to citizens_consent_path
    end

    private

    def import_bank_data
      command = TrueLayer::BankDataImportService.call(
        applicant: applicant,
        token: token,
        token_expires_at: token_expires_at
      )

      # TODO: Show better error message to the user
      flash[:error] = command.errors.to_a.flatten.join(', ') unless command.success?
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

    def credentials
      @credentials ||= request.env['omniauth.auth'].credentials
    end

    def applicant
      @applicant ||= current_applicant
    end
  end
end
