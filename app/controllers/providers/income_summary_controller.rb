module Providers
  class IncomeSummaryController < ProviderBaseController
    def index
      @bank_transactions = bank_transactions
      @cash_transactions = cash_transactions
    end

    def create
      return continue_or_draft if draft_selected?

      if uncategorized_transactions?
        @bank_transactions = bank_transactions
        @cash_transactions = cash_transactions
        render :index
      else
        go_forward
      end
    end

    private

    def uncategorized_transactions?
      @legal_aid_application.uncategorised_transactions?(:credit)
    end

    def bank_transactions
      @legal_aid_application.bank_transactions
                            .credit
                            .order(happened_at: :desc)
                            .by_type
    end

    def cash_transactions
      cash_transaction_types
      @legal_aid_application.cash_transactions.credits.order(transaction_date: :desc)
    end

    def cash_transaction_types
      @cash_transaction_types ||= @legal_aid_application.cash_transactions.credits.pluck(:name).uniq
    end
  end
end
