module TrueLayer
  module Importers
    class ImportAccountsService
      def initialize(api_client, bank_provider)
        @api_client = api_client
        @bank_provider = bank_provider
      end

      def call
        bank_provider.bank_accounts.each do |account|
          account.bank_transactions.clear
        end
        bank_provider.bank_accounts.clear
        bank_provider.bank_accounts.create!(mapped_resources)
      end

      private

      attr_reader :api_client, :bank_provider

      def mapped_resources
        true_layer_resources.map do |resource|
          {
            true_layer_response: resource,
            true_layer_id: resource[:account_id],
            name: resource[:display_name],
            currency: resource[:currency],
            account_number: resource[:account_number][:number],
            sort_code: resource[:account_number][:sort_code]
          }
        end
      end

      def true_layer_resources
        @true_layer_resources ||= api_client.accounts
      end
    end
  end
end
