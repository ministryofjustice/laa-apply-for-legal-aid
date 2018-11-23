module Citizens
  class ConsentsController < BaseController
    def show
      @applicant = current_applicant
    end

    def create
      @form = Applicants::OpenBankingConsentForm.new(edit_params)

      case params[:legal_aid_application][:open_banking_consent]
      when 'YES'
        @form.save
        redirect_to applicant_true_layer_omniauth_authorize_path
      when 'NO'
        @form.save
        render plain: 'Landing page: No Consent provided'
        # redirect_to citizens_information_path
      end
    end

    private

    def edit_params
      consent_params.merge(model: current_applicant.legal_aid_application)
    end

    def consent_params
      params.require(:legal_aid_application).permit(:open_banking_consent, :consented_at)
    end
  end
end
