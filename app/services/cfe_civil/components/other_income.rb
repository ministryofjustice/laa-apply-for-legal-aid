module CFECivil
  module Components
    class OtherIncome < BaseDataBlock
      def call
        {
          other_incomes: other_income_data,
        }.to_json
      end

    private

      def other_income_data
        grouped_transactions.keys.sort_by(&:name).each_with_object([]) do |transaction_type, array|
          array << all_transactions_of_one_type(transaction_type, grouped_transactions[transaction_type])
        end
      end

      def all_transactions_of_one_type(transaction_type, transactions)
        {
          source: transaction_type.name.humanize,
          payments: transactions.map { |t| single_transaction_hash(t) },
        }
      end

      def single_transaction_hash(transaction)
        {
          date: transaction.happened_at.strftime("%Y-%m-%d"),
          amount: transaction.amount.to_f,
          client_id: transaction.id,
        }
      end

      def grouped_transactions
        @grouped_transactions ||= legal_aid_application
                                    .bank_transactions
                                    .credit
                                    .where(transaction_type_id: other_income_transaction_type_ids)
                                    .order(:happened_at)
                                    .group_by(&:transaction_type)
      end

      def other_income_transaction_type_ids
        TransactionType.other_income.pluck(:id)
      end
    end
  end
end
