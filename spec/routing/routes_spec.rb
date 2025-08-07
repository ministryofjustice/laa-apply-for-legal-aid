require "rails_helper"

RSpec.describe "Routes" do
  describe "GET /ping" do
    it "renders the correct route" do
      expect(get: "/ping").to route_to("status#ping")
    end
  end
end
