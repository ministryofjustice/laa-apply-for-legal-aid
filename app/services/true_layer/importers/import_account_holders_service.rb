module TrueLayer
  module Importers
    class ImportAccountHoldersService
      prepend SimpleCommand

      def initialize(api_client, bank_provider)
        @api_client = api_client
        @bank_provider = bank_provider
      end

      def call
        if true_layer_error
          errors.add(:import_account_holders, true_layer_error)
        else
          bank_provider.bank_account_holders.clear
          bank_provider.bank_account_holders.create!(mapped_resources)
        end
      end

      private

      attr_reader :api_client, :bank_provider

      def mapped_resources
        account_holders.map do |account_holder|
          {
            true_layer_response: account_holder,
            full_name: account_holder[:full_name],
            addresses: account_holder[:addresses],
            date_of_birth: account_holder[:date_of_birth]&.to_date
          }
        end
      end

      def true_layer_error
        true_layer_resource.error
      end

      def account_holders
        true_layer_resource.value
      end

      def true_layer_resource
        @true_layer_resource ||= api_client.account_holders
      end
    end
  end
end
