require "rails_helper"

RSpec.describe MojComponentsHelper do
  context "when interruption_card is called with a heading and a block" do
    subject(:interruption_card) { helper.interruption_card(heading: "Heading") { "Body" } }

    it "renders the interruption card template with the heading and body" do
      expected_html = <<~HTML
        <div class="moj-interruption-card">
          <div class="moj-interruption-card__content">
            <div class="govuk-grid-row">
              <div class="govuk-grid-column-two-thirds">
                <h1 class="govuk-heading-l moj-interruption-card__heading">Heading</h1>
                Body
              </div>
            </div>
          </div>
        </div>
      HTML

      expect(interruption_card).to eq(expected_html)
    end
  end
end
