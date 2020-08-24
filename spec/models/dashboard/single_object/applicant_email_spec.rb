require 'rails_helper'

module Dashboard
  module SingleObject
    RSpec.describe ApplicantEmail do
      subject(:dashboard_applicant_email) { described_class.new(application) }

      let(:geckoboard_client) { double Geckoboard::Client }
      let(:datasets_client) { double Geckoboard::DatasetsClient }
      let(:dataset) { double Geckoboard::Dataset }

      before do
        allow(Geckoboard).to receive(:client).and_return(geckoboard_client)
        allow(geckoboard_client).to receive(:ping).and_return(true)
        allow(geckoboard_client).to receive(:datasets).and_return(datasets_client)
      end

      let(:application) { create :legal_aid_application, :with_applicant }

      it { is_expected.to be_a Dashboard::SingleObject::ApplicantEmail }

      describe '.build_row' do
        subject(:build_row) { dashboard_applicant_email.build_row }

        let(:expected_response) do
          [
            {
              timestamp: application.created_at,
              reference: application.application_ref
            }
          ]
        end

        it 'returns an array summarising the application' do
          is_expected.to eql expected_response
        end
      end

      describe '.run' do
        subject(:run) { dashboard_applicant_email.run }

        it 'submits data to geckoboard' do
          expect(datasets_client).to receive(:find_or_create).and_return(dataset)
          expect(dataset).to receive(:post)
          run
        end
      end
    end
  end
end
