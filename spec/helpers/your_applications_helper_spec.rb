require "rails_helper"

RSpec.describe YourApplicationsHelper do
  describe "#your_applications_default_tab_path" do
    it "returns the path for the default tab on the your applications page" do
      expect(helper.your_applications_default_tab_path).to eq(in_progress_providers_legal_aid_applications_path)
    end
  end
end
