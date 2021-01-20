module TrueLayer
  module Importers
    class ImportProviderService
      prepend SimpleCommand

      def initialize(api_client:, applicant:, token_expires_at:)
        @api_client = api_client
        @applicant = applicant
        @token = token
        @token_expires_at = token_expires_at
      end

      def call
        if true_layer_error
          errors.add(:import_provider, true_layer_error)
        else
          import_provider
        end
      end

      private

      attr_reader :api_client, :applicant, :token, :token_expires_at

      def import_provider
        bank_provider = applicant.bank_providers.find_or_create_by!(
          true_layer_provider_id: provider[:provider][:provider_id]
        )
        ActiveRecord::Base.logger.silence do
          bank_provider.update!(mapped_resource)
        end
        bank_provider
      end

      def mapped_resource
        {
          true_layer_response: provider,
          credentials_id: provider[:credentials_id],
          token: applicant.true_layer_secure_data_id,
          token_expires_at: token_expires_at,
          name: provider[:provider][:display_name],
          true_layer_provider_id: provider[:provider][:provider_id]
        }
      end

      def true_layer_error
        true_layer_resource.error
      end

      def provider
        true_layer_resource.value.first
      end

      def true_layer_resource
        @true_layer_resource ||= api_client.provider
      end
    end
  end
end
