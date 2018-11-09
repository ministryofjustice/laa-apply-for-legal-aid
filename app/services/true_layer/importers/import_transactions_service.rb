module TrueLayer
  module Importers
    class ImportTransactionsService
      def initialize(api_client, bank_account)
        @api_client = api_client
        @bank_account = bank_account
      end

      def call
        bank_account.bank_transactions.clear
        bank_account.bank_transactions.create!(mapped_resources)
      end

      private

      attr_reader :api_client, :bank_account

      def mapped_resources
        true_layer_resources.map do |resource|
          {
            true_layer_response: resource,
            true_layer_id: resource[:transaction_id]
          }
        end
      end

      def true_layer_resources
        @true_layer_resources ||= api_client.transactions(bank_account.true_layer_id, date_from, date_to)
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
