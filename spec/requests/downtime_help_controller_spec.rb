require "rails_helper"

RSpec.describe "downtime help page" do
  describe "GET /downtime_help#guidance" do
    it "returns renders successfully" do
      get downtime_help_path
      expect(response).to have_http_status(:ok)
    end

    it "displays help about applications created before the downtime" do
      get downtime_help_path

      expect(page)
        .to have_css("h1", text: "Guidance for submitting delegated functions applications after service downtime")
        .and have_css("h2", text: "Help with questions that may be confusing")
        .and have_css("h3", text: "Do you want to request a higher emergency cost limit?")
        .and have_css("h3", text: "Do you want to make a substantive application now?")
        .and have_css("h3", text: "Which bank accounts does your client have?")
        .and have_css("h3", text: "Has a date been set for the hearing?")
    end
  end
end
