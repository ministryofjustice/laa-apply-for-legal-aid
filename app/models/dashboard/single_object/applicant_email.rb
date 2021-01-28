module Dashboard
  module SingleObject
    class ApplicantEmail
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
            reference: @application.application_ref
          }
        ]
      end

      private

      def dataset_name
        "apply_for_legal_aid.#{HostEnv.environment}.applicant_email"
      end

      def dataset_definition
        {
          fields: [
            Geckoboard::DateTimeField.new(:timestamp, name: 'Time'),
            Geckoboard::StringField.new(:reference, name: 'Reference')
          ]
        }
      end

      def log_start_message
        log_message("***** ApplicantEmail starting job at #{Time.current} for dataset: #{dataset_name}")
      end

      def log_data_message
        log_message "***** ApplicantEmail sending: #{build_row} job at #{Time.current} for dataset: #{dataset_name}"
      end

      def log_message(message)
        Rails.logger.info message unless Rails.env.test?
      end
    end
  end
end
