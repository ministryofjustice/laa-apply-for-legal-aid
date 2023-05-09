module CFECivil
  module Components
    class Outgoings < BaseDataBlock
      def call
        {
          outgoings: build_transactions,
        }.to_json
      end

    private

      def build_transactions
        bank_transactions.each_with_object([]) do |(transaction_type_id, array), result|
          name = TransactionType.find(transaction_type_id).name
          type_hash = { name:, payments: transactions(name, array) }
          result << type_hash
        end
      end

      def transactions(name, array)
        array.each_with_object([]) do |transaction, result|
          data_block = {
            payment_date: transaction.happened_at.strftime("%Y-%m-%d"),
            amount: transaction.amount.abs.to_f,
            client_id: transaction.id,
          }
          data_block[:housing_cost_type] = legal_aid_application.own_home? ? "mortgage" : "rent" if name == "rent_or_mortgage"
          result << data_block
        end
      end

      def bank_transactions
        @bank_transactions ||= legal_aid_application
                                 .bank_transactions
                                 .debit
                                 .where.not(transaction_type_id: nil)
                                 .order(:happened_at)
                                 .group_by(&:transaction_type_id)
      end
    end
  end
end
