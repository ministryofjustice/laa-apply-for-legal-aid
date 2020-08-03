module Providers
  class OpenBankingConsentsController < ProviderBaseController
    def show
      puts '1'
      legal_aid_application.reset_from_use_ccms! if legal_aid_application.use_ccms?
      puts '2'
      legal_aid_application.provider_confirm_applicant_eligibility!
      puts '3'
      @form = LegalAidApplications::OpenBankingConsentForm.new(model: legal_aid_application)
      puts '4'
    end

    def update
      puts '5'
      @form = LegalAidApplications::OpenBankingConsentForm.new(form_params)
      puts '9'
      render :show unless save_continue_or_draft(@form)
      puts '10'
    end

    private

    def form_params
        puts '6'
      merge_with_model(legal_aid_application) do
        puts '7'
        return {} unless params[:legal_aid_application]
        puts '8'
        params.require(:legal_aid_application).permit(:provider_received_citizen_consent)
      end
    end
  end
end
