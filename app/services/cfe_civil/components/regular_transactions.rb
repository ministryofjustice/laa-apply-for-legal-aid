module CFECivil
  module Components
    class RegularTransactions < BaseDataBlock
      def call
        {
          regular_transactions: build_regular_transactions,
        }.to_json
      end

    private

      def party
        @party ||= legal_aid_application.send(owner_type.downcase)
      end

      def build_regular_transactions
        party.regular_transactions.each_with_object([]) do |regular_transaction, payload|
          payload << {
            category: regular_transaction.transaction_type.name,
            operation: regular_transaction.transaction_type.operation,
            amount: regular_transaction.amount.to_f,
            frequency: regular_transaction.frequency,
          }
        end
      end
    end
  end
end
