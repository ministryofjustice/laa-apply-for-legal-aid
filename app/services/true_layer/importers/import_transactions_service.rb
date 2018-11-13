module TrueLayer
  module Importers
    class ImportTransactionsService
      prepend SimpleCommand

      def initialize(api_client, bank_account)
        @api_client = api_client
        @bank_account = bank_account
      end

      def call
        if true_layer_error
          errors.add(:import_transactions, true_layer_error)
        else
          bank_account.bank_transactions.clear
          bank_account.bank_transactions.create!(mapped_resources)
        end
      end

      private

      attr_reader :api_client, :bank_account

      def mapped_resources
        transactions.map do |transaction|
          {
            true_layer_response: transaction,
            true_layer_id: transaction[:transaction_id],
            description: transaction[:description],
            merchant: transaction[:merchant_name],
            currency: transaction[:currency],
            amount: transaction[:amount],
            happened_at: transaction[:timestamp],
            operation: transaction[:transaction_type]&.downcase
          }
        end
      end

      def true_layer_error
        true_layer_resource.error
      end

      def transactions
        true_layer_resource.value
      end

      def true_layer_resource
        @true_layer_resource ||= api_client.transactions(bank_account.true_layer_id, date_from, date_to)
      end

      def date_to
        @date_to ||= Time.now
      end

      def date_from
        @date_from ||= (date_to - 3.months - 1.day).beginning_of_day
      end
    end
  end
end
