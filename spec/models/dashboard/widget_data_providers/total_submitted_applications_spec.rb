require 'rails_helper'

module Dashboard
  module WidgetDataProviders
    RSpec.describe TotalSubmittedApplications do
      describe '.handle' do
        it 'returns the unqualified widget name' do
          expect(described_class.handle).to eq 'total_submitted_applications'
        end
      end

      describe '.dataset_definition' do
        it 'returns hash of field definitions' do
          expected_definition = '{"fields":[{"name":"Applications","optional":false,"type":"number"}]}'
          expect(described_class.dataset_definition.to_json).to eq expected_definition
        end
      end

      describe '.data' do
        it 'returns the expected data' do
          create_applications
          expect(described_class.data).to eq expected_data
        end

        def expected_data
          [
            {
              'number' => MeritsAssessment.count
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
          }.each do |num_days, num_submitted_applications|
            num_submitted_applications.times do
              FactoryBot.create(:merits_assessment, submitted_at: num_days.days.ago)
            end
          end
        end
      end
    end
  end
end
