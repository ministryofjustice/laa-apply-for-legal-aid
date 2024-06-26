require "rails_helper"

module Dashboard
  module SingleObject
    RSpec.describe ApplicantEmail do
      subject(:dashboard_applicant_email) { described_class.new(application) }

      let(:geckoboard_client) { instance_double Geckoboard::Client }
      let(:application) { create(:legal_aid_application, :with_applicant) }
      let(:datasets_client) { instance_double Geckoboard::DatasetsClient }
      let(:dataset) { instance_double Geckoboard::Dataset }

      before do
        allow(Geckoboard).to receive(:client).and_return(geckoboard_client)
        allow(geckoboard_client).to receive_messages(ping: true, datasets: datasets_client)
      end

      it { is_expected.to be_a described_class }

      describe ".build_row" do
        subject(:build_row) { dashboard_applicant_email.build_row }

        let(:expected_response) do
          [
            {
              timestamp: application.created_at,
              reference: application.application_ref,
            },
          ]
        end

        it "returns an array summarising the application" do
          expect(build_row).to eql expected_response
        end
      end

      describe ".run" do
        subject(:run) { dashboard_applicant_email.run }

        before { allow(datasets_client).to receive(:find_or_create).and_return(dataset) }

        it "submits data to geckoboard" do
          expect(dataset).to receive(:post)
          run
        end
      end
    end
  end
end
