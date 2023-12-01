require "rails_helper"

module Dashboard
  RSpec.describe FeedbackItemJob do
    describe ".perform" do
      subject(:feedback_item_job) { described_class.perform_now(feedback) }

      let(:feedback) { create(:feedback, :from_provider, satisfaction: 2, difficulty: 4) }
      let(:suspended_list) { Rails.configuration.x.suspended_dashboard_updater_jobs }

      let(:geckoboard_client) { instance_double Geckoboard::Client }
      let(:datasets_client) { instance_double Geckoboard::DatasetsClient }
      let(:dataset) { instance_double Geckoboard::Dataset }

      before do
        allow(Geckoboard).to receive(:client).and_return(geckoboard_client)
        allow(geckoboard_client).to receive(:ping).and_return(true)
        allow(geckoboard_client).to receive(:datasets).and_return(datasets_client)
        allow(Rails.configuration.x.suspended_dashboard_updater_jobs).to receive(:include?).with("Dashboard::FeedbackItemJob").and_return(false)
      end

      describe "#perform" do
        context "when in the production environment" do
          before { allow(HostEnv).to receive(:environment).and_return(:production) }

          context "and the job is not in the suspended list" do
            it "runs the geckoboard feedback updater" do
              expect_any_instance_of(Dashboard::SingleObject::Feedback).to receive(:run)
              feedback_item_job
            end
          end
        end

        context "when in the UAT environment" do
          before { allow(HostEnv).to receive(:environment).and_return(:uat) }

          context "and the job is not in the suspended list" do
            it "does not run the geckoboard feedback updater" do
              expect_any_instance_of(Dashboard::SingleObject::Feedback).not_to receive(:run)
              feedback_item_job
            end
          end
        end
      end
    end
  end
end
