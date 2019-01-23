module Citizens
  class ConsentsController < ApplicationController
    include Flowable

    def show; end

    def create
      @form = Applicants::OpenBankingConsentForm.new(edit_params)

      @form.save

      if @form.open_banking_consent == 'true'
        redirect_to applicant_true_layer_omniauth_authorize_path
      else
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

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find(session[:current_application_ref])
    end
  end
end
