require "rails_helper"

module Dashboard
  RSpec.describe ProviderDataJob do
    describe ".perform" do
      subject(:provider_data_job) { described_class.perform_now(provider) }

      let(:provider) { create(:provider) }
      let(:suspended_list) { Rails.configuration.x.suspended_dashboard_updater_jobs }

      let(:geckoboard_client) { double Geckoboard::Client }
      let(:datasets_client) { double Geckoboard::DatasetsClient }
      let(:dataset) { double Geckoboard::Dataset }

      before do
        allow(Geckoboard).to receive(:client).and_return(geckoboard_client)
        allow(geckoboard_client).to receive(:ping).and_return(true)
        allow(geckoboard_client).to receive(:datasets).and_return(datasets_client)
      end

      describe "#perform" do
        context "when in the production environment" do
          before { allow(HostEnv).to receive(:environment).and_return(:production) }

          context "and the job is not in the suspended list" do
            it "runs ProviderData" do
              expect_any_instance_of(Dashboard::SingleObject::ProviderData).to receive(:run)
              provider_data_job
            end
          end
        end

        context "when in the test environment" do
          before { allow(HostEnv).to receive(:environment).and_return(:test) }

          context "and the job is not in the suspended list" do
            it "does not run ProviderData" do
              expect_any_instance_of(Dashboard::SingleObject::ProviderData).not_to receive(:run)
              provider_data_job
            end
          end
        end
      end
    end
  end
end
