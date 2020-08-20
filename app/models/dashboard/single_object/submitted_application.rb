module Dashboard
  module SingleObject
    class SubmittedApplication
      def initialize(application)
        @application = application
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
            timestamp: @application.created_at,
            passported: @application.passported? ? 1 : 0,
            nonpassported: @application.passported? ? 0 : 1
          }
        ]
      end

      private

      def dataset_name
        "apply_for_legal_aid.#{HostEnv.environment}.submitted_applications.details"
      end

      def dataset_definition
        {
          fields: [
            Geckoboard::DateTimeField.new(:timestamp, name: 'Time'),
            Geckoboard::NumberField.new(:passported, name: 'Passported'),
            Geckoboard::NumberField.new(:nonpassported, name: 'Nonpassported')
          ]
        }
      end

      def log_start_message
        log_message("***** SubmittedApplication starting job at #{Time.now} for dataset: #{dataset_name}")
      end

      def log_data_message
        log_message "***** SubmittedApplication sending: #{build_row} job at #{Time.now} for dataset: #{dataset_name}"
      end

      def log_message(message)
        puts message unless Rails.env.test?
      end
    end
  end
end
