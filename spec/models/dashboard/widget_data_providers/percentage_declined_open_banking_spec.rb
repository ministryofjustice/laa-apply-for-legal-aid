require 'rails_helper'

module Dashboard
  module WidgetDataProviders
    RSpec.describe PercentageDeclinedOpenBanking do
      describe '.handle' do
        it 'returns the unqualified widget name' do
          expect(described_class.handle).to eq 'declined_open_banking'
        end
      end

      describe '.dataset_definition' do
        it 'returns hash of field definitions' do
          expected_definition = '{"fields":[{"name":"Percentage that declined open banking consent","optional":false,"type":"number"}]}'
          expect(described_class.dataset_definition.to_json).to eq expected_definition
        end
      end

      describe '.data' do
        context 'no to open banking consent' do
          let(:application) { create :legal_aid_application, open_banking_consent: false }
          let(:application2) { create :legal_aid_application, open_banking_consent: true }
          let(:expected_data) { [{ 'declined_open_banking' => 50 }] }
          before do
            application
            application2
          end

          it 'sends expected data' do
            expect(described_class.data).to eq expected_data
          end
        end

        context 'yes to open banking consent' do
          let(:application) { create :legal_aid_application, open_banking_consent: true }
          let(:expected_data) { [{ 'declined_open_banking' => 0 }] }

          before { application }

          it 'data is unchanged' do
            expect(described_class.data).to eq expected_data
          end
        end
      end
    end
  end
end
