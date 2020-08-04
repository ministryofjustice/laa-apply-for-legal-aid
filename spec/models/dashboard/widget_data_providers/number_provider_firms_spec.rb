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

        context 'five users over three firms' do
          let(:firm1) { create :firm }
          let(:firm2) { create :firm }
          let(:firm3) { create :firm }

          before do
            create :provider, username: 'user1-firm1', firm: firm1
            create :provider, username: 'user2-firm1', firm: firm1
            create :provider, username: 'user1-firm2', firm: firm2
            create :provider, username: 'user2-firm2', firm: firm2
            create :provider, username: 'user1-firm3', firm: firm3
          end

          it 'expects the firm count to include all firms' do
            expect(described_class.data).to eq [{ 'number' => 3 }]
          end
        end
      end
    end
  end
end
