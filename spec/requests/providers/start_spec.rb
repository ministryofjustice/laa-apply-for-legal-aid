require "rails_helper"

RSpec.describe "provider start of journey test" do
  describe "GET /providers" do
    before do
      # Manually clear the page_history_service as it crosses test and local server boundaries
      Redis.new(url: Rails.configuration.x.redis.page_history_url).set("page_history:", "[]")
      get providers_root_path
    end

    let(:page_history_service) { PageHistoryService.new(page_history_id: session[:page_history_id]) }

    it "returns http success" do
      expect(response).to have_http_status(:ok)
    end

    it "does not log page history" do
      expect(JSON.parse(page_history_service.read)).to be_empty
    end
  end
end
