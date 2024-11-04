module Providers
  class OutgoingsSummaryController < ProviderBaseController
    def index
      setup
    end

    def create
      return continue_or_draft if draft_selected?

      if uncategorized_transactions?
        setup
        render :index
      else
        go_forward
      end
    end

  private

    def setup
      @transaction_types = TransactionType.where(id: @legal_aid_application.individual_transaction_type_ids("Applicant")).debits
      @total_transaction_types = TransactionType.debits
      @bank_transactions = bank_transactions
      @cash_transactions = cash_transactions
    end

    def uncategorized_transactions?
      @legal_aid_application.uncategorised_transactions?(:debit)
    end

    def bank_transactions
      @legal_aid_application.bank_transactions
                            .debit
                            .order(happened_at: :desc)
                            .by_type
    end

    def cash_transactions
      cash_transaction_types
      @legal_aid_application.cash_transactions.debits.order(transaction_date: :desc)
    end

    def cash_transaction_types
      @cash_transaction_types ||= @legal_aid_application.cash_transactions.debits.pluck(:name).uniq
    end
  end
end
