module Citizens
  class ConsentsController < CitizenBaseController
    def show
      @legal_aid_application.reset_to_applicant_entering_means! if @legal_aid_application.use_ccms?
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
      if @form.open_banking_consent != "true"
        legal_aid_application.use_ccms!(:no_applicant_consent)
        clear_employment_status
      end
    end

    def clear_employment_status
      legal_aid_application.applicant.employed = nil
      legal_aid_application.applicant.save!
    end

    def form_params
      merge_with_model(legal_aid_application) do
        return {} unless params[:legal_aid_application]

        params.expect(legal_aid_application: %i[open_banking_consent open_banking_consent_choice_at])
      end
    end
  end
end
