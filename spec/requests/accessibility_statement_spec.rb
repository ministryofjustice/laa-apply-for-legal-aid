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
        .and have_content("How we tested this website")
        .and have_content("The Equality and Human Rights Commission (EHRC) is responsible for enforcing the accessibility regulations.")
        .and have_content("Reporting accessibility problems")
        .and have_link("AbilityNet has advice on making your device easier to use", href: "https://mcmw.abilitynet.org.uk/")
        .and have_link("contact the Equality Advisory and Support Service (EASS).", href: "https://www.equalityadvisoryservice.com/")
        .and have_link("Web Content Accessibility Guidelines (WCAG) version 2.1", href: "https://www.w3.org/TR/WCAG21/")
    end
  end
end
