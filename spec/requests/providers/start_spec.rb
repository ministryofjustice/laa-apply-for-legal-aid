require "rails_helper"

RSpec.describe "provider start of journey test" do
  describe "GET /providers" do
    before do
      allow(Setting).to receive_messages(public_law_family?: public_law_family)
      get providers_root_path
    end

    let(:public_law_family) { false }

    it "returns http success" do
      expect(response).to have_http_status(:ok)
    end

    it "does not show the PLF list item" do
      expect(page).to have_no_content("public law family")
    end

    context "when the PLF feature flag is on" do
      let(:public_law_family) { true }

      it { expect(page).to have_css("li", text: "public law family") }
    end
  end
end
