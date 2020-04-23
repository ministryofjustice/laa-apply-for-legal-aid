module Citizens
  class ConsentsController < CitizenBaseController
    def show
      @form = Applicants::OpenBankingConsentForm.new(model: legal_aid_application)
    end

    def update
      @form = Applicants::OpenBankingConsentForm.new(form_params)
      if @form.save
        change_application_state
        go_forward
      else
        render :show
      end
    end

    private

    def change_application_state
      if @form.open_banking_consent == 'true'
        legal_aid_application.provider_submit! unless legal_aid_application.provider_submitted?
      else
        legal_aid_application.use_ccms! unless legal_aid_application.use_ccms?
      end
    end

    def form_params
      merge_with_model(legal_aid_application) do
        return {} unless params[:legal_aid_application]

        params.require(:legal_aid_application).permit(:open_banking_consent, :open_banking_consent_choice_at)
      end
    end
  end
end
