# Past week's average feedback score
module Dashboard
  module WidgetDataProviders
    class PastWeeksAverageFeedbackScore
      def self.dataset_definition
        {
          fields: [
            Geckoboard::NumberField.new(:number, name: "Past Week's Average Feedback score")
          ]
        }
      end

      def self.data
        [
          {
            'number' => calculate_average
          }
        ]
      end

      def self.handle
        'past_weeks_average_feedback_score'
      end

      def self.calculate_average
        records = Feedback.where(created_at: 7.days.ago.beginning_of_day..Time.now)
        total = records.map(&:satisfaction_before_type_cast).sum
        (total.to_f / records.size).round(1)
      end
    end
  end
end
