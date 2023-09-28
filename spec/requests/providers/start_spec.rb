require "rails_helper"

RSpec.describe "provider start of journey test" do
  describe "GET /providers" do
    before do
      get providers_root_path
    end

    it "returns http success" do
      expect(response).to have_http_status(:ok)
    end
  end
end
