module Providers
  class ApplicantBankAccountsController < ProviderBaseController
    def show
      applicant_accounts
      applicant_bank_account_form
    end

    def update
      if applicant_bank_account_form.valid?
        reset_account_balance unless applicant_bank_account_form.applicant_bank_account?
        return go_forward(applicant_bank_account_form.applicant_bank_account?)
      end
      applicant_accounts
      render :show
    end

    private

    def applicant_bank_account_form
      @form ||= BinaryChoiceForm.call(
        journey: :provider,
        radio_buttons_input_name: :applicant_bank_account,
        form_params: form_params
      )
    end

    def applicant_accounts
      @applicant_accounts ||= applicant.bank_providers.collect do |bank_provider|
        ApplicantAccountPresenter.new(bank_provider)
      end
    end

    def reset_account_balance
      return if legal_aid_application.savings_amount.blank?

      legal_aid_application.savings_amount[:offline_savings_accounts] = nil
      legal_aid_application.savings_amount.save
    end

    def form_params
      return {} unless params[:binary_choice_form]

      params.require(:binary_choice_form).permit(:applicant_bank_account)
    end
  end
end
