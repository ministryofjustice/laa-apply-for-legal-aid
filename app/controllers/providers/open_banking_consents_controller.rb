module Providers
  class OpenBankingConsentsController < ProviderBaseController
    def show
      legal_aid_application.reset_from_use_ccms! if legal_aid_application.use_ccms?
      legal_aid_application.provider_confirm_applicant_eligibility!
      @form = LegalAidApplications::OpenBankingConsentForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::OpenBankingConsentForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

    private

    def form_params
      merge_with_model(legal_aid_application) do
        return {} unless params[:legal_aid_application]

        params.require(:legal_aid_application).permit(:provider_received_citizen_consent)
      end
    end
  end
end
