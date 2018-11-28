module Citizens
  class ConsentsController < BaseController
    def show
      @applicant = current_applicant
    end

    def create
      @form = Applicants::OpenBankingConsentForm.new(edit_params)

      @form.save

      case @form.open_banking_consent
      when 'true'
        redirect_to applicant_true_layer_omniauth_authorize_path
      when 'false'
        render plain: 'Landing page: No Consent provided'
        # redirect_to citizens_information_path
      end
    end

    private

    def edit_params
      consent_params.merge(model: current_applicant.legal_aid_application)
    end

    def consent_params
      params.require(:legal_aid_application).permit(:open_banking_consent, :open_banking_consent_choice_at)
    end
  end
end
