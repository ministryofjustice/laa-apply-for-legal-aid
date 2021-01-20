module TrueLayer
  module Importers
    class ImportAccountsService
      prepend SimpleCommand

      def initialize(api_client, bank_provider)
        @api_client = api_client
        @bank_provider = bank_provider
      end

      def call
        if true_layer_error
          errors.add(:import_accounts, true_layer_error)
        else
          import_accounts
        end
      end

      private

      attr_reader :api_client, :bank_provider

      def import_accounts
        bank_provider.bank_accounts.each do |account|
          account.bank_transactions.clear
        end
        bank_provider.bank_accounts.clear
        ActiveRecord::Base.logger.silence do
          bank_provider.bank_accounts.create!(mapped_resources)
        end
      end

      def mapped_resources
        accounts.map do |account|
          {
            true_layer_response: account,
            true_layer_id: account[:account_id],
            name: account[:display_name],
            account_type: account[:account_type],
            currency: account[:currency],
            account_number: account[:account_number][:number],
            sort_code: account[:account_number][:sort_code]
          }
        end
      end

      def true_layer_error
        true_layer_resource.error
      end

      def accounts
        true_layer_resource.value
      end

      def true_layer_resource
        @true_layer_resource ||= api_client.accounts
      end
    end
  end
end
