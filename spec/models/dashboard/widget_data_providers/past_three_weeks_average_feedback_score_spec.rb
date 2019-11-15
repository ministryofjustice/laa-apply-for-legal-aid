require 'rails_helper'

module Dashboard
  module WidgetDataProviders
    RSpec.describe PastThreeWeeksAverageFeedbackScore do
      describe '.handle' do
        it 'returns the unqualified widget name' do
          expect(described_class.handle).to eq 'past_three_weeks_average_feedback_score'
        end
      end

      describe '.dataset_definition' do
        it 'returns hash of field definitions' do
          expected_definition = %q({"fields":[{"name":"Past Three Weeks' Average Feedback score","optional":false,"type":"number"}]})
          expect(described_class.dataset_definition.to_json).to eq expected_definition
        end
      end

      describe '.data' do
        it 'returns the expected data' do
          create_feedbacks

          expect(described_class.data).to eq expected_data
        end

        def expected_data
          [{ 'number' => (14.0 / 7).round(1) }]
        end

        def create_feedbacks # rubocop:disable Metrics/AbcSize
          {
            22.days.ago => 4,
            16.days.ago => 2,
            15.days.ago => 3,
            12.days.ago => 1,
            7.days.ago => 3,
            6.days.ago => 3,
            3.days.ago => 2,
            1.days.ago => 0
          }.each do |date, feedback_score|
            FactoryBot.create :feedback, satisfaction: Feedback.satisfactions.invert[feedback_score], created_at: date
          end
        end
      end
    end
  end
end
