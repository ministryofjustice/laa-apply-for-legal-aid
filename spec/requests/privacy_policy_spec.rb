require "rails_helper"

RSpec.describe "privacy policy page" do
  describe "GET /privacy_policy" do
    it "returns renders successfully" do
      get privacy_policy_index_path
      expect(response).to have_http_status(:ok)
    end

    it "display contact information" do
      get privacy_policy_index_path
      expect(response.body).to include("The Data Protection Officer")
      expect(response.body).to include("Purpose of processing and the lawful basis for the process")
      expect(response.body).to include("<a href='http://www.ico.org.uk'>ico.org.uk</a>")
    end
  end
end
