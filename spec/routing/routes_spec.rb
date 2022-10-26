require "rails_helper"

RSpec.describe "Routes" do
  describe "GET /status" do
    it "renders the correct route" do
      expect(get: "/status").to route_to("status#ping")
    end
  end
end
