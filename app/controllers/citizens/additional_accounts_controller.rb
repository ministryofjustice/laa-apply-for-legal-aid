module Citizens
  class AdditionalAccountsController < CitizenBaseController
    def index
      legal_aid_application.update!(has_offline_accounts: nil)
      legal_aid_application.reset_to_applicant_entering_means! if legal_aid_application.use_ccms?
      legal_aid_application.applicant_enter_means! unless legal_aid_application.applicant_entering_means?
      additional_account_form
    end

    def new
      legal_aid_application.reset_to_applicant_entering_means! if legal_aid_application.use_ccms?
      offline_account_form
    end

    def create
      return go_additional_account if additional_account_form_valid_and_additional_account?
      return go_forward if additional_account_form.valid?

      render :index
    end

    def update
      return update_offline_accounts_and_go_forward if offline_account_form_valid_and_has_offline_accounts?
      return update_online_accounts_and_go_citizens_banks if offline_account_form.valid?

      render :new
    end

  private

    def additional_account_form_valid_and_additional_account?
      additional_account_form.valid? && additional_account_form.additional_account?
    end

    def offline_account_form_valid_and_has_offline_accounts?
      offline_account_form.valid? && offline_account_form.has_offline_accounts?
    end

    def additional_account_form
      @additional_account_form ||= BinaryChoiceForm.call(
        journey: :citizen,
        radio_buttons_input_name: :additional_account,
        action: :index,
        form_params:,
      )
    end

    def offline_account_form
      @offline_account_form ||= BinaryChoiceForm.call(
        journey: :citizen,
        radio_buttons_input_name: :has_offline_accounts,
        action: :new,
        form_params:,
      )
    end

    def update_online_accounts_and_go_citizens_banks
      online_accounts_update
      go_citizen_banks
    end

    def update_offline_accounts_and_go_forward
      offline_accounts_update
      go_forward
    end

    def online_accounts_update
      legal_aid_application.update!(has_offline_accounts: false)
    end

    def offline_accounts_update
      legal_aid_application.update!(has_offline_accounts: true)
      legal_aid_application.use_ccms!(:offline_accounts) unless legal_aid_application.use_ccms?
    end

    def go_additional_account
      redirect_to new_citizens_additional_account_path
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
