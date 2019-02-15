module Providers
  class ClientReceivedLegalHelpsController < ProviderBaseController
    before_action :authorize_legal_aid_application

    def show
      @form = MeritsAssessments::ClientReceivedLegalHelpForm.new(model: merits_assessment)
    end

    def update
      @form = MeritsAssessments::ClientReceivedLegalHelpForm.new(client_received_legal_help_params.merge(model: merits_assessment))

      render :show unless save_continue_or_draft(@form)
    end

    private

    def merits_assessment
      @merits_assessment ||= legal_aid_application.merits_assessment || legal_aid_application.build_merits_assessment
    end

    def client_received_legal_help_params
      params.require(:merits_assessment).permit(:client_received_legal_help, :application_purpose)
    end

    def authorize_legal_aid_application
      authorize legal_aid_application
    end
  end
end
