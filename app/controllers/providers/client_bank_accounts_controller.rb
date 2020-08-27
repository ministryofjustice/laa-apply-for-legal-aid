module Providers
  class ClientBankAccountsController < ProviderBaseController
    def show
      applicant_accounts
    end

    def update
      if params[:offline_savings_account].in?(%w[yes no])
        go_forward(params[:offline_savings_account] == 'yes')
        # The of statement below is used to delete the value for offline_savings_account if the user returns to the page from CYA and selects the No radio button
        # if params[:offline_savings_account] == 'no'
        #   legal_aid_application.savings_amount[:offline_savings_accounts] = nil
        #   legal_aid_application.savings_amount.save
        # end
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
  end
end
