module Dashboard
  module WidgetDataProviders
    class FeedbackScores
      MULTIPLIERS = {
        0 => %w[very_dissatisfied very_difficult],
        25 => %w[dissatisfied difficult],
        50 => %w[neither_dissatisfied_nor_satisfied neither_difficult_nor_easy],
        75 => %w[satisfied easy],
        100 => %w[very_satisfied very_easy]
      }.freeze

      def self.dataset_definition
        {
          fields: [
            Geckoboard::NumberField.new(:three_week_average_difficulty, name: 'three_week_average_difficulty'),
            Geckoboard::NumberField.new(:three_week_average, name: 'three_week_average'),
            Geckoboard::NumberField.new(:three_week_count, name: 'three_week_count'),
            Geckoboard::NumberField.new(:one_week_average_difficulty, name: 'one_week_average_difficulty'),
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
            'three_week_average_difficulty' => calculate_average(@three_week_data, :difficulty),
            'three_week_average' => calculate_average(@three_week_data, :satisfaction),
            'three_week_count' => @three_week_data.count,
            'one_week_average_difficulty' => calculate_average(@one_week_data, :difficulty),
            'one_week_average' => calculate_average(@one_week_data, :satisfaction),
            'one_week_count' => @one_week_data.count
          }
        ]
      end

      def self.calculate_average(records, field)
        total = 0
        values = records.map(&field).sort.group_by(&:itself).transform_values(&:count)
        values.each do |description, count|
          multiplier = MULTIPLIERS.map { |key, value| key if value.include?(description) }.compact.first
          total += count * multiplier unless count.nil?
        end
        total /= records.count unless records.count.zero?
        total
      end
    end
  end
end
