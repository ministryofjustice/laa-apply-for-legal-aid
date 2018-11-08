module TrueLayer
  module Importers
    class ImportAccountBalanceService
      def initialize(api_client, bank_account)
        @api_client = api_client
        @bank_account = bank_account
      end

      def call
        return unless true_layer_resource

        bank_account.update!(mapped_resource)
      end

      private

      attr_reader :api_client, :bank_account

      def mapped_resource
        {
          true_layer_balance_response: true_layer_resource,
          balance: true_layer_resource[:current]
        }
      end

      def true_layer_resource
        @true_layer_resource ||= api_client.account_balance(bank_account.true_layer_id)
      end
    end
  end
end
