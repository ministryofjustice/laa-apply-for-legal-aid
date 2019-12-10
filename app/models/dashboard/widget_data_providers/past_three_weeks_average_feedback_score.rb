# Past 3 week's average feedback score
module Dashboard
  module WidgetDataProviders
    class PastThreeWeeksAverageFeedbackScore
      def self.dataset_definition
        {
          fields: [
            Geckoboard::NumberField.new(:number, name: "Past Three Weeks' Average Feedback score")
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
        'past_three_weeks_average_feedback_score'
      end

      def self.calculate_average
        records = Feedback.where(created_at: 3.weeks.ago.beginning_of_day..Time.now)
        total = records.map(&:satisfaction_before_type_cast).sum
        total.zero? ? total : ((total * 25.0) / records.size).round(1)
      end
    end
  end
end
