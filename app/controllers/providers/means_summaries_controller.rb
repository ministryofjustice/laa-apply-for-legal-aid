module Providers
  class MeansSummariesController < ProviderBaseController
    helper_method :date_from, :date_to

    def show
      authorize legal_aid_application
      @bank_transaction_amounts = bank_transactions.group(:transaction_type_id).sum(:amount)
    end

    private

    def date_from
      l(bank_transactions.last.happened_at.to_date, format: :long_date)
    end

    def date_to
      l(bank_transactions.first.happened_at.to_date, format: :long_date)
    end

    def bank_transactions
      legal_aid_application.bank_transactions
    end
  end
end
