module CFE
  class CreateCashTransactionsService < BaseService
    def cfe_url_path
      "/assessments/#{@submission.assessment_id}/cash_transactions"
    end

    def request_body
      {
        income: build_cash_transactions_for(:credit),
        outgoings: build_cash_transactions_for(:debit)
      }.to_json
    end

    private

    def cash_transactions
      @cash_transactions ||= legal_aid_application.cash_transactions
    end

    def cash_transactions_for(operation)
      cash_transactions.joins(:transaction_type).where(transaction_type: { operation: operation })
                       .order('transaction_type.name', :transaction_date)
                       .group_by(&:transaction_type_id)
    end

    def build_cash_transactions_for(operation)
      result = []

      cash_transactions_for(operation).each do |transaction_type_id, array|
        category = TransactionType.find(transaction_type_id).name
        type_hash = { category: category, payments: transactions(array) }
        result << type_hash
      end
      result
    end

    def transactions(array)
      result = []
      array.each do |transaction|
        result << {
          date: transaction.transaction_date.strftime('%Y-%m-%d'),
          amount: transaction.amount.abs.to_f,
          client_id: transaction.id
        }
      end
      result
    end

    def process_response
      @submission.cash_transactions_created!
    end
  end
end
