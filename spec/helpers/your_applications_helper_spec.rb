require "rails_helper"

RSpec.describe YourApplicationsHelper do
  describe "#home_path" do
    subject(:link) { home_path }

    context "when called on provider journey" do
      before do
        allow(request).to receive(:path_info).and_return("/providers/test")
      end

      it { is_expected.to eq(in_progress_providers_legal_aid_applications_path) }
    end

    context "when called on citizens journey" do
      before do
        allow(request).to receive(:path_info).and_return("/citizens/test")
      end

      it { is_expected.to eq("#") }
    end
  end

  describe "#your_applications_default_tab_path" do
    it "returns the path for the default tab on the your applications page" do
      expect(helper.your_applications_default_tab_path).to eq(in_progress_providers_legal_aid_applications_path)
    end
  end
end
