module Citizens
  class AdditionalAccountsController < CitizenBaseController
    def index
      legal_aid_application.update!(has_offline_accounts: nil)
      legal_aid_application.reset_to_applicant_entering_means! if legal_aid_application.use_ccms?
      legal_aid_application.applicant_enter_means! unless legal_aid_application.applicant_entering_means?
      additional_account_form
    end

    def create
      if additional_account_form.valid?
        return additional_account_form.additional_account? ? go_additional_account : go_forward
      end

      render :index
    end

    def new
      legal_aid_application.reset_to_applicant_entering_means! if legal_aid_application.use_ccms?
      offline_account_form
    end

    def update
      if offline_account_form.valid?
        if offline_account_form.has_offline_accounts?
          offline_accounts_update
          return go_forward
        else
          online_accounts_update
          return go_citizen_banks
        end
      end

      render :new
    end

    private

    def additional_account_form
      @additional_account_form ||= BinaryChoiceForm.call(
        journey: :citizen,
        radio_buttons_input_name: :additional_account,
        action: :index,
        form_params: form_params
      )
    end

    def offline_account_form
      @offline_account_form ||= BinaryChoiceForm.call(
        journey: :citizen,
        radio_buttons_input_name: :has_offline_accounts,
        action: :new,
        form_params: form_params
      )
    end

    def go_citizen_banks
      redirect_to citizens_banks_path
    end

    def go_additional_account
      redirect_to new_citizens_additional_account_path
    end

    def online_accounts_update
      legal_aid_application.update!(has_offline_accounts: false)
    end

    def offline_accounts_update
      legal_aid_application.update(has_offline_accounts: true)
      legal_aid_application.use_ccms!(:offline_accounts) unless legal_aid_application.use_ccms?
    end

    def form_params
      return {} unless params[:binary_choice_form]

      params.require(:binary_choice_form).permit(:additional_account, :has_offline_accounts)
    end
  end
end
