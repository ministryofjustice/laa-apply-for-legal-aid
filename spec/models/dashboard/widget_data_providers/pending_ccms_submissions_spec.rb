require 'rails_helper'

module Dashboard
  module WidgetDataProviders
    RSpec.describe PendingCCMSSubmissions do
      describe '.handle' do
        it 'returns the unqualified widget name' do
          expect(described_class.handle).to eq 'pending_ccms_submissions'
        end
      end

      describe '.dataset_definition' do
        it 'returns hash of field definitions' do
          expected_definition = '{"fields":[{"name":"Pending CCMS Submissions","optional":false,"type":"number"}]}'
          expect(described_class.dataset_definition.to_json).to eq expected_definition
        end
      end

      describe '.data' do
        let(:aasm_states) { CCMS::Submission.aasm.states.map(&:name) - %i[failed completed] }
        let(:expected_data) { [{ 'number' => 4 }] }
        it 'sends expected data' do
          4.times do
            create :ccms_submission, aasm_state: aasm_states.sample
          end
          create :ccms_submission, aasm_state: 'failed'
          create :ccms_submission, aasm_state: 'completed'
          expect(described_class.data).to eq expected_data
        end
      end
    end
  end
end
