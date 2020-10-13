require 'rails_helper'

module Reports
  module MIS
    DATE_TIME_REGEX = /^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$/.freeze

    RSpec.describe NonPassportedApplicationCsvLine do
      describe '.header_row' do
        let(:expected_header_row) do
          %w[
            application_ref
            state
            username
            provider_email
            created_at
          ]
        end
        it 'returns column headings' do
          expect(described_class.header_row).to eq expected_header_row
        end
      end

      describe '.call' do
        let(:application) { create :legal_aid_application }
        let(:provider) { application.provider }
        let(:time) { Time.new(2020, 9, 20, 2, 3, 44) }

        subject { described_class.call(application) }

        it 'returns an array of five fields' do
          expect(subject.size).to eq 5
        end

        it 'returns an array with the expected values' do
          Timecop.freeze(time)
          fields = subject
          expect(fields[0]).to eq application.application_ref
          expect(fields[1]).to eq application.state
          expect(fields[2]).to eq provider.username
          expect(fields[3]).to eq provider.email
          expect(fields[4]).to match DATE_TIME_REGEX
        end
      end
    end
  end
end
