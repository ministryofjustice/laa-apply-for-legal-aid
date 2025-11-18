require "rails_helper"

RSpec.describe MojComponent::AlertComponent, type: :component do
  subject do
    render_inline(described_class.new(type:, heading:, body:, dismiss_href:, dismiss_text: "Dismiss", dismiss_method: :post))
  end

  let(:type) { :information }
  let(:heading) { "Heading text" }
  let(:body) { "Body text" }
  let(:dismiss_href) { "made-up-url" }
  let(:dismiss_text) { "Remove" }
  let(:dismiss_method) { :get }

  context "when alerrt is called with everything" do
    it "renders the alert with heading, body and dismiss url" do
      expect(rendered_content).to have_css("moj-alert.h2.alert__content.alert__heading", text: "Heading text")
      expect(rendered_content).to have_css("moj-alert.h2.alert__content", text: "Body text")
    end
  end

  context "when alert is called without a type" do
    let(:type) { nil }

    it "raises an argument error" do
      expect(rendered_content).to raise_error(ArgumentError)
    end
  end
end
