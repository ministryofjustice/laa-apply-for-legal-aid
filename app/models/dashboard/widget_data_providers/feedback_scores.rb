module Dashboard
  module WidgetDataProviders
    class FeedbackScores
      MULTIPLIERS = {
        'very_dissatisfied': 0,
        'dissatisfied': 25,
        'neither_dissatisfied_nor_satisfied': 50,
        'satisfied': 75,
        'very_satisfied': 100
      }.freeze

      def self.dataset_definition
        {
          fields: [
            Geckoboard::NumberField.new(:three_week_average, name: 'three_week_average'),
            Geckoboard::NumberField.new(:three_week_count, name: 'three_week_count'),
            Geckoboard::NumberField.new(:one_week_average, name: 'one_week_average'),
            Geckoboard::NumberField.new(:one_week_count, name: 'one_week_count')
          ]
        }
      end

      def self.handle
        'feedback_scores'
      end

      def self.data
        @one_week_data = Feedback.where(created_at: 7.days.ago.beginning_of_day..Time.now)
        @three_week_data = Feedback.where(created_at: 3.weeks.ago.beginning_of_day..Time.now)
        [
          {
            'three_week_average' => calculate_average(@three_week_data),
            'three_week_count' => @three_week_data.count,
            'one_week_average' => calculate_average(@one_week_data),
            'one_week_count' => @one_week_data.count
          }
        ]
      end

      def self.calculate_average(records)
        total = 0
        values = records.map(&:satisfaction).sort.group_by(&:itself).transform_values(&:count)
        MULTIPLIERS.each_pair do |score, multiplier|
          total += values[score.to_s] * multiplier unless values[score.to_s].nil?
        end
        total /= records.count unless records.count.zero?
        total
      end
    end
  end
end
