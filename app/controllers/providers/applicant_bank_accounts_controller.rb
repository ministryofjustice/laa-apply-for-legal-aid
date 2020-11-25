module Providers
  class ApplicantBankAccountsController < ProviderBaseController
    def show
      applicant_accounts
    end

    def update
      if params[:offline_savings_account].in?(%w[true false])
        go_forward(params[:offline_savings_account] == 'true')
        reset_account_balance if params[:offline_savings_account] == 'false'
      else
        @error = { 'offline_savings_account-error' => I18n.t('providers.applicant_bank_accounts.show.error') }
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
      legal_aid_application.savings_amount.save
    end
  end
end
