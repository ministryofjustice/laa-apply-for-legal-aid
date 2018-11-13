module TrueLayer
  module Importers
    class ImportAccountBalanceService
      prepend SimpleCommand

      def initialize(api_client, bank_account)
        @api_client = api_client
        @bank_account = bank_account
      end

      def call
        if true_layer_error
          errors.add(:import_account_balance, true_layer_error)
        else
          bank_account.update!(mapped_resource)
        end
      end

      private

      attr_reader :api_client, :bank_account

      def mapped_resource
        {
          true_layer_balance_response: account_balance,
          balance: account_balance[:current]
        }
      end

      def true_layer_error
        true_layer_resource.error
      end

      def account_balance
        true_layer_resource.value.first
      end

      def true_layer_resource
        @true_layer_resource ||= api_client.account_balance(bank_account.true_layer_id)
      end
    end
  end
end
