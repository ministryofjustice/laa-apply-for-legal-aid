module Providers
  class NoIncomeSummariesController < ProviderBaseController
    def show
      # @bank_transactions = bank_transactions
    end

    def update
      ap params[:confirm_no_income]
      if params[:confirm_no_income].in?(%w[yes no])
        go_forward(params[:confirm_no_income] == 'yes')
      else
        @error = { 'confirm_no_income-error' => I18n.t('providers.income_summaries.no_income_summary.error') }
        render :show
      end
    end

    private

    def bank_transactions
      @legal_aid_application.bank_transactions
          .credit
          .order(happened_at: :desc)
          .by_type
    end
  end
end