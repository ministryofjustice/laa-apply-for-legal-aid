module TrueLayer
  module Importers
    class ImportAccountHoldersService
      def initialize(api_client, bank_provider)
        @api_client = api_client
        @bank_provider = bank_provider
      end

      def call
        bank_provider.bank_account_holders.clear
        bank_provider.bank_account_holders.create!(mapped_resources)
      end

      private

      attr_reader :api_client, :bank_provider

      def mapped_resources
        true_layer_resources.map do |resource|
          {
            true_layer_response: resource,
            full_name: resource[:full_name],
            full_address: resource[:addresses]&.map do |address|
              address.values.join(', ')
            end&.join('; '),
            date_of_birth: resource[:date_of_birth]&.to_date
          }
        end
      end

      def true_layer_resources
        @true_layer_resources ||= api_client.account_holders
      end
    end
  end
end
