require "rails_helper"

module Dashboard
  module SingleObject
    RSpec.describe Feedback do
      subject(:dashboard_feedback) { described_class.new(feedback) }

      let(:geckoboard_client) { instance_double Geckoboard::Client }
      let(:feedback) { create(:feedback, :from_provider, satisfaction: 2, difficulty: 4) }
      let(:datasets_client) { instance_double Geckoboard::DatasetsClient }
      let(:dataset) { instance_double Geckoboard::Dataset }

      before do
        allow(Geckoboard).to receive(:client).and_return(geckoboard_client)
        allow(geckoboard_client).to receive(:ping).and_return(true)
        allow(geckoboard_client).to receive(:datasets).and_return(datasets_client)
      end

      it { is_expected.to be_a described_class }

      describe ".build_row" do
        subject(:build_row) { dashboard_feedback.build_row }

        let(:expected_response) do
          [
            {
              timestamp: feedback.created_at,
              type: "Provider",
              difficulty_count: 4,
              difficulty_score: 100,
              satisfaction_count: 2,
              satisfaction_score: 50,
            },
          ]
        end

        it "returns an array summarising the feedback" do
          expect(build_row).to eql expected_response
        end
      end

      describe ".run" do
        subject(:run) { dashboard_feedback.run }

        before { allow(datasets_client).to receive(:find_or_create).and_return(dataset) }

        it "submits data to geckoboard" do
          expect(dataset).to receive(:post)
          run
        end
      end
    end
  end
end
