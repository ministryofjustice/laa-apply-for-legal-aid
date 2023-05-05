module CFECivil
  module Components
    class CashTransactions < BaseDataBlock
      delegate :cash_transactions, to: :legal_aid_application

      def call
        {
          cash_transactions: {
            income: build_cash_transactions_for(:credit),
            outgoings: build_cash_transactions_for(:debit),
          },
        }.to_json
      end

    private

      def cash_transactions_for(operation)
        cash_transactions.joins(:transaction_type).where(transaction_type: { operation: })
                         .order("transaction_type.name", :transaction_date)
                         .group_by(&:transaction_type_id)
      end

      def build_cash_transactions_for(operation)
        result = []

        cash_transactions_for(operation).each do |transaction_type_id, array|
          category = TransactionType.find(transaction_type_id).name
          type_hash = { category:, payments: transactions(array) }
          result << type_hash
        end
        result
      end

      def transactions(array)
        array.each_with_object([]) do |transaction, result|
          result << {
            date: transaction.transaction_date.strftime("%Y-%m-%d"),
            amount: transaction.amount.abs.to_f,
            client_id: transaction.id,
          }
        end
      end
    end
  end
end
