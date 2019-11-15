require 'rails_helper'

module Dashboard
  module WidgetDataProviders
    RSpec.describe FailedCCMSSubmissions do
      describe '.handle' do
        it 'returns the unqualified widget name' do
          expect(described_class.handle).to eq 'ccms_submission_failures'
        end
      end

      describe '.dataset_definition' do
        it 'returns hash of field definitions' do
          expected_definition = '{"fields":[{"name":"Date","type":"date"},{"name":"Submissions","optional":false,"type":"number"}],"unique_by":["date"]}'
          expect(described_class.dataset_definition.to_json).to eq expected_definition
        end
      end

      describe '.data' do
        let(:aasm_states) { CCMS::Submission.aasm.states.map(&:name) - [:failed] }
        let(:dates) { (8.days.ago.to_date..2.days.ago.to_date).to_a }
        it 'sends expected data' do
          4.times do
            create :ccms_submission, aasm_state: aasm_states.sample, created_at: dates.sample
          end
          create :ccms_submission, aasm_state: 'failed', created_at: 8.days.ago
          create :ccms_submission, aasm_state: 'failed', created_at: 3.days.ago
          create :ccms_submission, aasm_state: 'failed', created_at: 3.days.ago
          create :ccms_submission, aasm_state: 'failed', created_at: Time.now

          expect(described_class.data).to eq expected_data
        end

        def expected_data # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          [
            { 'date' => 6.days.ago.strftime('%Y-%m-%d'),
              'number' => 0 },
            { 'date' => 5.days.ago.strftime('%Y-%m-%d'),
              'number' => 0 },
            { 'date' => 4.days.ago.strftime('%Y-%m-%d'),
              'number' => 0 },
            { 'date' => 3.days.ago.strftime('%Y-%m-%d'),
              'number' => 2 },
            { 'date' => 2.days.ago.strftime('%Y-%m-%d'),
              'number' => 0 },
            { 'date' => 1.days.ago.strftime('%Y-%m-%d'),
              'number' => 0 },
            { 'date' => Date.today.strftime('%Y-%m-%d'),
              'number' => 1 }
          ]
        end
      end
    end
  end
end
