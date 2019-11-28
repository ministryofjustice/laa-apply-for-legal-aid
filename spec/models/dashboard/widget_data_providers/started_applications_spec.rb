require 'rails_helper'

module Dashboard
  module WidgetDataProviders
    RSpec.describe StartedApplications do
      describe '.handle' do
        it 'returns the unqualified widget name' do
          expect(described_class.handle).to eq 'started_applications'
        end
      end

      describe '.dataset_definition' do
        it 'returns hash of field definitions' do
          expected_definition = '{"fields":[{"name":"Date","type":"date"},{"name":"Applications","optional":false,"type":"number"}],"unique_by":["date"]}'
          expect(described_class.dataset_definition.to_json).to eq expected_definition
        end
      end

      describe '.data' do
        it 'returns the expected data' do
          create_applications
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

        def create_applications
          {
            7 => 2,
            6 => 3,
            3 => 1,
            2 => 5,
            1 => 3,
            0 => 1
          }.each do |num_days, num_apps|
            num_apps.times do
              FactoryBot.create :legal_aid_application, created_at: num_days.days.ago
            end
          end
        end
      end
    end
  end
end
