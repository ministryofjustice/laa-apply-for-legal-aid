module Providers
  class ApplicantBankAccountsController < ProviderBaseController
    def show
      applicant_accounts
      @form = SavingsAmounts::OfflineSavingsAccountsForm.new(model: savings_amount)
    end

    def update
      @form = SavingsAmounts::OfflineSavingsAccountsForm.new(form_params)

      reset_account_balance if @form.valid? && @form.offline_savings_accounts.blank?

      applicant_accounts
      render :show unless save_continue_or_draft(@form)
    end

  private

    def applicant_accounts
      @applicant_accounts ||= applicant.bank_providers.collect do |bank_provider|
        ApplicantAccountPresenter.new(bank_provider)
      end
    end

    def reset_account_balance
      return if legal_aid_application.savings_amount.blank?

      legal_aid_application.savings_amount[:offline_savings_accounts] = nil
      legal_aid_application.savings_amount.save!
    end

    def savings_amount
      @savings_amount ||= legal_aid_application.savings_amount || legal_aid_application.build_savings_amount
    end

    def form_params
      merge_with_model(savings_amount) do
        params.expect(savings_amount: [:offline_savings_accounts, :applicant_bank_account])
      end
    end
  end
end
