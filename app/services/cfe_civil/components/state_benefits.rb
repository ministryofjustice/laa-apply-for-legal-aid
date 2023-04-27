module CFECivil
  module Components
    class StateBenefits < BaseDataBlock
      def call
        {
          state_benefits: build_transactions,
        }.to_json
      end

    private

      def build_transactions
        result = []

        raise CFECivil::SubmissionError, "Benefit transactions un-coded" if bank_transactions.keys.any?(nil)

        bank_transactions.each do |meta_data, array|
          type_hash = { name: meta_data[:label], payments: transactions(array) }
          result << type_hash
        end
        result
      end

      def transactions(array)
        array.each_with_object([]) do |transaction, result|
          result << {
            date: transaction.happened_at.strftime("%Y-%m-%d"),
            amount: transaction.amount.to_f,
            client_id: transaction.id,
          }
          result.first[:flags] = transaction.flags if transaction.flags.present?
        end
      end

      def bank_transactions
        @bank_transactions ||= legal_aid_application
                                 .bank_transactions
                                 .where(transaction_type_id: benefit_transaction_type_ids)
                                 .order(:happened_at)
                                 .group_by(&:meta_data)
      end

      def benefit_transaction_type_ids
        TransactionType.where(name: %i[benefits excluded_benefits]).pluck :id
      end
    end
  end
end
