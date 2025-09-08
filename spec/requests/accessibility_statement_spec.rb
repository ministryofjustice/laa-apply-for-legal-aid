require "rails_helper"

RSpec.describe "accessibility statement page" do
  describe "GET /accessibility_statement" do
    it "returns renders successfully" do
      get accessibility_statement_index_path
      expect(response).to have_http_status(:ok)
    end

    it "display accessibility information" do
      get accessibility_statement_index_path

      expect(page)
        .to have_css("h1", text: "Accessibility statement")
        .and have_css("h2", text: "How you should be able to use this website")
        .and have_css("h2", text: "Feedback and contact information")
        .and have_css("h2", text: "Enforcement procedure")
        .and have_css("h2", text: "Technical information about this service's accessibility")
        .and have_css("h2", text: "Compliance status")
        .and have_css("h2", text: "Non-accessible content")
        .and have_css("h2", text: "Third-party content")
        .and have_css("h2", text: "What we're doing to improve accessibility")
        .and have_css("h2", text: "Preparation of this accessibility statement")
        .and have_link("AbilityNet has advice on making your device easier to use", href: "https://mcmw.abilitynet.org.uk/")
        .and have_link("contact the Equality Advisory and Support Service (EASS).", href: "https://www.equalityadvisoryservice.com/")
        .and have_link("Web Content Accessibility Guidelines (WCAG) version 2.1", href: "https://www.w3.org/TR/WCAG21/")
    end
  end
end
