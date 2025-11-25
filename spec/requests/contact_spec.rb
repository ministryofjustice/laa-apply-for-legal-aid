require "rails_helper"

RSpec.describe "contact page" do
  describe "GET /contact" do
    it "returns renders successfully" do
      get contact_path
      expect(response).to have_http_status(:ok)
    end

    it "display contact information" do
      get contact_path

      expect(page)
        .to have_content("Telephone: 0203 8144 350")
        .and have_link("Online Support (opens in new tab)", href: "https://legalaidlearning.justice.gov.uk/online-support-2/")
    end
  end
end
