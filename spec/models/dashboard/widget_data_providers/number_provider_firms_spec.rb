require 'rails_helper'

module Dashboard
  module WidgetDataProviders
    RSpec.describe NumberProviderFirms do
      describe '.handle' do
        it 'returns the unqualified widget name' do
          expect(described_class.handle).to eq 'number_provider_firms'
        end
      end

      describe '.dataset_definition' do
        it 'returns hash of field definitions' do
          expected_definition = '{"fields":[{"name":"Firms","optional":false,"type":"number"}]}'
          expect(described_class.dataset_definition.to_json).to eq expected_definition
        end
      end

      describe '.data' do
        context 'no one has ever logged in' do
          let(:expected_data) { [{ 'number' => 0 }] }
          it 'sends expected data' do
            expect(described_class.data).to eq expected_data
          end
        end

        context 'three users over two firms' do
          before do
            firm1 = create :firm
            firm2 = create :firm
            create :provider, firm: firm1
            create :provider, firm: firm1
            create :provider, firm: firm2
          end

          let(:expected_data) { [{ 'number' => 2 }] }
          it 'sends expected data' do
            expect(described_class.data).to eq expected_data
          end
        end
      end
    end
  end
end
