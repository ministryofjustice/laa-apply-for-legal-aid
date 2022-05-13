require "rails_helper"

module Dashboard
  RSpec.describe UpdaterJob do
    let(:suspended_list) { Rails.configuration.x.suspended_dashboard_updater_jobs }

    describe "#perform" do
      context "when in the production environment" do
        before { allow(HostEnv).to receive(:environment).and_return(:production) }

        context "and job is not in the suspended list" do
          it "instantiates widget with the specified parameter" do
            expect(Dashboard::Widget).to receive(:new).with("MyWidget").and_return(double("WidgetDataProvider", run: nil))
            described_class.perform_now("MyWidget")
          end
        end
      end

      context "when in the test environment" do
        context "and job is in the suspended list" do
          it "does not instantiate widget with the specified parameter" do
            expect(Dashboard::Widget).not_to receive(:new).with("MyWidget")
            described_class.perform_now("MyWidget")
          end
        end
      end
    end
  end
end
