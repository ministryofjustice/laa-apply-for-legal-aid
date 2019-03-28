module Providers
  class MeansSummariesController < ProviderBaseController
    helper_method :date_from, :date_to

    def show
      authorize legal_aid_application
      @bank_transaction_amounts = bank_transactions.group(:transaction_type_id).sum(:amount)
    end

    def update
      authorize legal_aid_application
      continue_or_draft
    end

    private

    def date_from
      l(legal_aid_application.transaction_period_start_at.to_date, format: :long_date)
    end

    def date_to
      l(legal_aid_application.transaction_period_finish_at.to_date, format: :long_date)
    end

    def bank_transactions
      legal_aid_application.bank_transactions
    end
  end
end
