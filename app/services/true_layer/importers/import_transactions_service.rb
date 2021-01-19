module TrueLayer
  module Importers
    class ImportTransactionsService
      prepend SimpleCommand

      def initialize(api_client, bank_account, start_at:, finish_at:)
        @api_client = api_client
        @bank_account = bank_account
        @start_at = start_at
        @finish_at = finish_at
      end

      def call
        if true_layer_error
          errors.add(:import_transactions, true_layer_error)
        else
          bank_account.bank_transactions.clear
          ActiveRecord::Base.logger.silence do
            bank_account.bank_transactions.create!(mapped_resources)
          end
        end
      end

      private

      attr_reader :api_client, :bank_account, :start_at, :finish_at

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
            operation: transaction[:transaction_type]&.downcase,
            running_balance: transaction.dig(:running_balance, :amount)
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
        @true_layer_resource ||= api_client.transactions(bank_account.true_layer_id, start_at, finish_at)
      end
    end
  end
end
