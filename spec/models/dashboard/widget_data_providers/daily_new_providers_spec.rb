require 'rails_helper'

module Dashboard
  module WidgetDataProviders # rubocop:disable Metrics/ModuleLength
    RSpec.describe DailyNewProviders do
      describe '.handle' do
        it 'returns the unqualified widget name' do
          expect(described_class.handle).to eq 'daily_new_providers'
        end
      end

      describe '.dataset_definition' do
        it 'returns hash of field definitions' do
          expected_definition = '{"fields":[{"name":"Date","type":"date"},{"name":"Applications","optional":false,"type":"number"}],"unique_by":["date"]}'
          expect(described_class.dataset_definition.to_json).to eq expected_definition
        end
      end

      describe '.data' do
        context 'no whitelist' do
          before { Rails.configuration.x.application.whitelisted_users = nil }
          it 'returns the expected data' do
            create_providers
            expect(described_class.data).to eq expected_data
          end

          def expected_data # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
            [
              {
                'date' => 6.days.ago.strftime('%Y-%m-%d'),
                'number' => 3
              },
              {
                'date' => 5.days.ago.strftime('%Y-%m-%d'),
                'number' => 0
              },
              {
                'date' => 4.days.ago.strftime('%Y-%m-%d'),
                'number' => 0
              },
              {
                'date' => 3.days.ago.strftime('%Y-%m-%d'),
                'number' => 1
              },
              {
                'date' => 2.days.ago.strftime('%Y-%m-%d'),
                'number' => 5
              },
              {
                'date' => 1.days.ago.strftime('%Y-%m-%d'),
                'number' => 3
              },
              {
                'date' => Date.today.strftime('%Y-%m-%d'),
                'number' => 1
              }
            ]
          end

          def create_providers
            {
              7 => 2,
              6 => 3,
              3 => 1,
              2 => 5,
              1 => 3,
              0 => 1
            }.each do |num_days, num_providers|
              num_providers.times do
                FactoryBot.create :provider, created_at: num_days.days.ago
              end
            end
          end
        end

        context 'with whitelist' do
          before do
            Rails.configuration.x.application.whitelisted_users = %w[user-1 user-3]
            create :provider, username: 'user-1', created_at: 2.days.ago
            create :provider, username: 'user-2', created_at: 2.days.ago
            create :provider, username: 'user-3', created_at: 4.days.ago
          end

          it 'only counts those users in the whitelist' do
            expect(described_class.data).to eq expected_data
          end

          def expected_data # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
            [
              {
                'date' => 6.days.ago.strftime('%Y-%m-%d'),
                'number' => 0
              },
              {
                'date' => 5.days.ago.strftime('%Y-%m-%d'),
                'number' => 0
              },
              {
                'date' => 4.days.ago.strftime('%Y-%m-%d'),
                'number' => 1
              },
              {
                'date' => 3.days.ago.strftime('%Y-%m-%d'),
                'number' => 0
              },
              {
                'date' => 2.days.ago.strftime('%Y-%m-%d'),
                'number' => 1
              },
              {
                'date' => 1.days.ago.strftime('%Y-%m-%d'),
                'number' => 0
              },
              {
                'date' => Date.today.strftime('%Y-%m-%d'),
                'number' => 0
              }
            ]
          end
        end
      end
    end
  end
end
