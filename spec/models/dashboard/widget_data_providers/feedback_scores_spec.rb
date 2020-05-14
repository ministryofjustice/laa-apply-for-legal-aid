require 'rails_helper'

module Dashboard
  module WidgetDataProviders
    RSpec.describe FeedbackScores do
      describe '.handle' do
        it 'returns the unqualified widget name' do
          expect(described_class.handle).to eq 'feedback_scores'
        end
      end

      describe '.dataset_definition' do
        it 'returns hash of field definitions' do
          expected_definition = { 'fields':
                                  [
                                    { 'name': 'three_week_average_difficulty', "optional": false, "type": 'number' },
                                    { 'name': 'three_week_average', "optional": false, "type": 'number' },
                                    { 'name': 'three_week_count', "optional": false, "type": 'number' },
                                    { 'name': 'one_week_average_difficulty', "optional": false, "type": 'number' },
                                    { 'name': 'one_week_average', "optional": false, "type": 'number' },
                                    { 'name': 'one_week_count', "optional": false, "type": 'number' }
                                  ] }.to_json
          expect(described_class.dataset_definition.to_json).to eq expected_definition
        end
      end

      describe '.data' do
        let(:date) { Date.new(2019, 12, 12) }

        context 'when data is present' do
          before { create_feedbacks }

          it 'returns the expected data' do
            travel_to(date) { expect(described_class.data).to eq expected_data }
          end

          def expected_data
            [
              {
                'three_week_average_difficulty' => 63,
                'three_week_average' => 63,
                'three_week_count' => 11,
                'one_week_average_difficulty' => 66,
                'one_week_average' => 66,
                'one_week_count' => 9
              }
            ]
          end

          def expected_feedback
            # pattern is days_ago => [v.dissatisfied, dissatisfied, neither_d_nor_s, satisfied, v.satisfied]
            {
              28 => [0, 0, 0, 0, 1],
              20 => [1, 0, 0, 0, 0],
              12 => [0, 0, 0, 0, 1],
              5 => [0, 0, 0, 1, 0],
              3 => [0, 1, 0, 0, 0],
              2 => [1, 0, 1, 0, 0],
              1 => [0, 0, 0, 2, 0],
              0 => [0, 0, 0, 0, 3]
            }
          end

          def create_feedbacks
            expected_feedback.each do |num_days, num_apps|
              travel_to(date - num_days.days) do
                (0..4).each do |level|
                  create_list :feedback, num_apps[level], satisfaction: level, difficulty: level if num_apps[level] > 0
                end
              end
            end
          end
        end

        context 'when minimal data is present' do
          before { create_feedbacks }

          it 'returns the expected data' do
            travel_to(date) { expect(described_class.data).to eq expected_data }
          end

          def expected_data
            [
              {
                'three_week_average_difficulty' => 50,
                'three_week_average' => 50,
                'three_week_count' => 10,
                'one_week_average_difficulty' => 50,
                'one_week_average' => 50,
                'one_week_count' => 10
              }
            ]
          end

          def expected_feedback
            # pattern is days_ago => [v.dissatisfied, dissatisfied, neither_d_nor_s, satisfied, v.satisfied]
            {
              0 => [2, 2, 2, 2, 2]
            }
          end

          def create_feedbacks
            expected_feedback.each do |num_days, num_apps|
              travel_to(date - num_days.days) do
                (0..4).each do |level|
                  FactoryBot.create_list :feedback, num_apps[level], satisfaction: level, difficulty: level if num_apps[level] > 0
                end
              end
            end
          end
        end

        context 'when no data is present' do
          it 'returns the expected data' do
            travel_to(date) { expect(described_class.data).to eq expected_data }
          end

          def expected_data
            [
              {
                'three_week_average_difficulty' => 0,
                'three_week_average' => 0,
                'three_week_count' => 0,
                'one_week_average_difficulty' => 0,
                'one_week_average' => 0,
                'one_week_count' => 0
              }
            ]
          end
        end
      end
    end
  end
end
