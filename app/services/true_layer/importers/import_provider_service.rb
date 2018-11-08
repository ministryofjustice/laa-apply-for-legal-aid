module TrueLayer
  module Importers
    class ImportProviderService
      def initialize(api_client, applicant, token)
        @api_client = api_client
        @applicant = applicant
        @token = token
      end

      def call
        return unless true_layer_resource

        bank_provider = applicant.bank_providers.find_or_create_by!(
          credentials_id: true_layer_resource[:credentials_id]
        )

        bank_provider.update!(mapped_resource)
        bank_provider
      end

      private

      attr_reader :api_client, :applicant, :token

      def mapped_resource
        {
          true_layer_response: true_layer_resource,
          credentials_id: true_layer_resource[:credentials_id],
          token: token,
          name: true_layer_resource[:provider][:display_name],
          true_layer_provider_id: true_layer_resource[:provider][:provider_id]
        }
      end

      def true_layer_resource
        @true_layer_resource ||= api_client.provider
      end
    end
  end
end
