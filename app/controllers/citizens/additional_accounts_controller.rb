module Citizens
  class AdditionalAccountsController < CitizenBaseController
    def index
      legal_aid_application.update!(has_offline_accounts: nil)
      legal_aid_application.reset_to_applicant_entering_means! if legal_aid_application.use_ccms?
      legal_aid_application.applicant_enter_means! unless legal_aid_application.applicant_entering_means?
      additional_account_form
    end

    def create
      return go_citizen_banks if additional_account_form_valid_and_additional_account?
      return go_forward if additional_account_form.valid?

      render :index
    end

  private

    def additional_account_form_valid_and_additional_account?
      additional_account_form.valid? && additional_account_form.additional_account?
    end

    def additional_account_form
      @additional_account_form ||= BinaryChoiceForm.call(
        journey: :citizen,
        radio_buttons_input_name: :additional_account,
        action: :index,
        form_params:,
      )
    end

    def go_citizen_banks
      redirect_to citizens_banks_path
    end

    def form_params
      return {} unless params[:binary_choice_form]

      params.expect(binary_choice_form: %i[additional_account has_offline_accounts])
    end
  end
end
