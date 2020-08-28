module Providers
  class ClientBankAccountsController < ProviderBaseController
    def show
      applicant_accounts
    end

    def update
      if params[:offline_savings_account].in?(%w[yes no])
        go_forward(params[:offline_savings_account] == 'yes')
        reset_account_balance if params[:offline_savings_account] == 'no'
      else
        @error = { 'offline_savings_account-error' => I18n.t('providers.client_bank_accounts.show.error') }
        applicant_accounts
        render :show
      end
    end

    private

    def applicant_accounts
      @applicant_accounts ||= applicant.bank_providers.collect do |bank_provider|
        ApplicantAccountPresenter.new(bank_provider)
      end
    end

    def reset_account_balance
      return unless legal_aid_application.savings_amount.present?

      legal_aid_application.savings_amount[:offline_savings_accounts] = nil
      legal_aid_application.save
    end
  end
end
