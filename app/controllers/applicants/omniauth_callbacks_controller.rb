# This controller handles the user's return from the True Layer Oauth2 authentication
# Note that you may need to restart the server to apply changes to this file.
module Applicants
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    before_action :authenticate_applicant!, only: [:true_layer]

    def true_layer
      if applicant
        import_bank_data
        set_flash_message(:notice, :success, kind: 'TrueLayer')
        redirect_to citizens_accounts_path
      else
        set_flash_message(:error, :failure, kind: 'TrueLayer', reason: 'Unable to find matching application')
        redirect_to citizens_consent_path
      end
    end

    def failure
      set_flash_message(:error, :failure, kind: 'TrueLayer', reason: 'Process cancelled')
      redirect_to citizens_consent_path
    end

    private

    def import_bank_data
      TrueLayer::BankDataImportService.new(
        applicant: applicant,
        token: credentials.token
      ).call
    end

    def credentials
      @credentials ||= request.env['omniauth.auth'].credentials
    end

    def applicant
      @applicant ||= current_applicant
    end
  end
end
