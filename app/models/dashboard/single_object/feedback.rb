module Dashboard
  module SingleObject
    class Feedback
      MULTIPLIERS = {
        0 => %w[very_dissatisfied very_difficult],
        25 => %w[dissatisfied difficult],
        50 => %w[neither_dissatisfied_nor_satisfied neither_difficult_nor_easy],
        75 => %w[satisfied easy],
        100 => %w[very_satisfied very_easy]
      }.freeze

      def initialize(feedback)
        @feedback = feedback
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
            timestamp: @feedback.created_at,
            type: @feedback.source ||= 'Unknown',
            difficulty_count: @feedback.difficulty_before_type_cast,
            difficulty_score: calculate_value_of(@feedback.difficulty),
            satisfaction_count: @feedback.satisfaction_before_type_cast,
            satisfaction_score: calculate_value_of(@feedback.satisfaction)
          }
        ]
      end

      private

      def dataset_name
        "apply_for_legal_aid.#{HostEnv.environment}.feedback"
      end

      def calculate_value_of(selection)
        return 0 if selection.nil?

        MULTIPLIERS.filter_map { |key, value| key if value.include?(selection.to_s) }.first
      end

      def dataset_definition
        {
          fields: [
            Geckoboard::DateTimeField.new(:timestamp, name: 'Time'),
            Geckoboard::StringField.new(:type, name: 'Source'),
            Geckoboard::NumberField.new(:difficulty_count, name: 'Difficulty count', optional: true),
            Geckoboard::NumberField.new(:difficulty_score, name: 'Difficulty score', optional: true),
            Geckoboard::NumberField.new(:satisfaction_count, name: 'Satisfaction count', optional: true),
            Geckoboard::NumberField.new(:satisfaction_score, name: 'Satisfaction score', optional: true)
          ]
        }
      end

      def log_start_message
        log_message("***** Feedback starting job at #{Time.current} for dataset: #{dataset_name}")
      end

      def log_data_message
        log_message "***** Feedback sending: #{build_row} job at #{Time.current} for dataset: #{dataset_name}"
      end

      def log_message(message)
        Rails.logger.info message unless Rails.env.test?
      end
    end
  end
end
