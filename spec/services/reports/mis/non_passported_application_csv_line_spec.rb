require 'rails_helper'

module Reports
  module MIS
    DATE_TIME_REGEX = /^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$/.freeze

    RSpec.describe NonPassportedApplicationCsvLine do
      describe '.header_row' do
        let(:expected_header_row) do
          %w[
            state
            ccms_reason
            username
            provider_email
            created_at
            date_submitted
            applicant_name
            deleted
          ]
        end
        it 'returns column headings' do
          expect(described_class.header_row).to eq expected_header_row
        end
      end

      describe '.call' do
        let(:application) { create :legal_aid_application, :with_applicant, :at_assessment_submitted }
        let(:provider) { application.provider }
        let(:applicant) { application.applicant }
        let(:time) { Time.zone.local(2020, 9, 20, 2, 3, 44) }

        subject { described_class.call(application) }

        it 'returns an array of nine fields' do
          expect(subject.size).to eq 8
        end

        context 'undiscarded application' do
          it 'returns an array with the expected values' do
            travel_to(time) do
              fields = subject
              expect(fields[0]).to eq application.state
              expect(fields[1]).to eq application.ccms_reason
              expect(fields[2]).to eq provider.username
              expect(fields[3]).to eq provider.email
              expect(fields[4]).to match DATE_TIME_REGEX
              expect(fields[5]).to match DATE_TIME_REGEX
              expect(fields[6]).to eq applicant.full_name
              expect(fields[7]).to eq ''
            end
          end
        end

        context 'discarded application' do
          before { application.discard! }
          it 'returns an array with the expected values' do
            travel_to(time) do
              fields = subject
              expect(fields[0]).to eq application.state
              expect(fields[1]).to eq application.ccms_reason
              expect(fields[2]).to eq provider.username
              expect(fields[3]).to eq provider.email
              expect(fields[4]).to match DATE_TIME_REGEX
              expect(fields[5]).to match DATE_TIME_REGEX
              expect(fields[6]).to eq applicant.full_name
              expect(fields[7]).to eq 'Y'
            end
          end
        end

        context 'data begins with a vulnerable character' do
          before { provider.email = '=malicious_code' }
          it 'returns the escaped text' do
            expect(subject[3]).to eq "'=malicious_code"
          end
        end
      end
    end
  end
end
