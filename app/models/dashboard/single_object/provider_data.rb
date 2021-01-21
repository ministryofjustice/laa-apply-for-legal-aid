module Dashboard
  module SingleObject
    class ProviderData
      def initialize(provider)
        @provider = provider
        log_start_message
        @client = Geckoboard.client(Rails.configuration.x.geckoboard.api_key)
        raise 'Unable to access Geckoboard' unless @client.ping
      end

      def run
        @dataset = @client.datasets.find_or_create(dataset_name, dataset_definition)
        @dataset.post(build_row, delete_by: :timestamp)
        log_data_message
      end

      def build_row
        [
          {
            reference: @provider.id,
            timestamp: @provider.created_at,
            firm: @provider.firm.name,
            count: @provider.legal_aid_applications.count
          }
        ]
      end

      private

      def dataset_name
        "apply_for_legal_aid.#{HostEnv.environment}.provider"
      end

      def dataset_definition
        {
          fields: [
            Geckoboard::StringField.new(:reference, name: 'Reference'),
            Geckoboard::DateTimeField.new(:timestamp, name: 'User added'),
            Geckoboard::StringField.new(:firm, name: 'Works for'),
            Geckoboard::NumberField.new(:count, name: 'Applications')
          ],
          unique_by: %w[timestamp reference]
        }
      end

      def log_start_message
        log_message("***** Provider starting job at #{Time.current} for dataset: #{dataset_name}")
      end

      def log_data_message
        log_message "***** Provider sending: #{build_row} job at #{Time.current} for dataset: #{dataset_name}"
      end

      def log_message(message)
        Rails.logger.info message unless Rails.env.test?
      end
    end
  end
end
