require "rails_helper"

RSpec.describe "provider start of journey test" do
  describe "GET /providers" do
    before do
      allow(Setting).to receive_messages(linked_applications?: linked_applications)
      get providers_root_path
    end

    let(:linked_applications) { false }

    it "returns http success" do
      expect(response).to have_http_status(:ok)
    end

    it "does not show the linked_applications list item" do
      expect(page).to have_no_content("you want to make both a family link and legal link to your application")
    end

    context "when the linked_applications feature flag is on" do
      let(:linked_applications) { true }

      it "shows the linked_applications list item" do
        expect(page).to have_css("li", text: "you want to make both a family link and legal link to your application")
      end
    end
  end
end
