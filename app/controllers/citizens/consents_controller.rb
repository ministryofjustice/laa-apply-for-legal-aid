module Citizens
  class ConsentsController < BaseController
    include ApplicationFromSession

    def show; end

    def create
      @form = Applicants::OpenBankingConsentForm.new(edit_params)

      @form.save

      if @form.open_banking_consent?
        go_forward
      else
        render plain: 'Landing page: No Consent provided'
      end
    end

    private

    def edit_params
      merge_with_model(legal_aid_application) do
        params.require(:legal_aid_application).permit(:open_banking_consent, :open_banking_consent_choice_at)
      end
    end
  end
end
