require "rails_helper"

RSpec.describe MojComponent::InterruptionCardComponent, type: :component do
  subject! do
    render_inline(described_class.new(heading: "Heading"))
  end

  context "when interruption_card is called with a heading only" do
    it "renders the interruption card template with the heading only" do
      expect(rendered_content).to have_css("h1.govuk-heading-l.moj-interruption-card__heading", text: "Heading")
      expect(rendered_content).to have_no_css("div.govuk-body.moj-interruption-card__body")
    end
  end

  context "when interruption_card is called with a heading and a body slot" do
    subject! do
      render_inline(described_class.new(heading: "Heading")) do |card|
        card.with_body { "Body" }
      end
    end

    it "renders the interruption card template with the heading and body" do
      expect(rendered_content).to have_css("h1.govuk-heading-l.moj-interruption-card__heading", text: "Heading")
      expect(rendered_content).to have_css("div.govuk-body.moj-interruption-card__body", text: "Body")
    end
  end

  context "when interruption_card is called with a heading, a body slot and an actions slot" do
    subject! do
      render_inline(described_class.new(heading: "Heading")) do |card|
        card.with_body { "Body" }
        card.with_actions { "My actions" }
      end
    end

    it "renders the interruption card template with the heading and body" do
      expect(rendered_content).to have_css("h1.govuk-heading-l.moj-interruption-card__heading", text: "Heading")
      expect(rendered_content).to have_css("div.govuk-body.moj-interruption-card__body", text: "Body")
      expect(rendered_content).to have_css("div.govuk-button-group.moj-interruption-card__actions", text: "My actions")
    end
  end
end
