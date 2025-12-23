require "rails_helper"

RSpec.describe MojComponent::AlertComponent, type: :component do
  let(:content) do
    render_inline(
      described_class.new(type:, heading:, body:, dismiss_href:, dismiss_text:, dismiss_method:),
    )
  end

  let(:type) { :information }
  let(:heading) { "Heading text" }
  let(:body) { "Body text" }
  let(:dismiss_href) { "made-up-url" }
  let(:dismiss_text) { "Remove" }
  let(:dismiss_method) { :get }

  context "when alert is called with everything" do
    it "renders the alert with heading, body and dismiss url" do
      expect(content)
        .to have_css(".moj-alert h2.moj-alert__heading", text: "Heading text")
        .and have_css(".moj-alert .moj-alert__content", text: "Body text")
        .and have_link("Remove", href: "made-up-url", class: "moj-alert__dismiss")
    end
  end

  context "when alert is called without a heading" do
    let(:heading) { nil }

    it "does not render any heading markup" do
      expect(content)
        .to have_no_css(".moj-alert h2.moj-alert__heading")
    end
  end

  context "when alert is called without a type" do
    let(:type) { nil }

    it "raises an argument error" do
      expect { content }.to raise_error(ArgumentError)
    end
  end

  context "when alert is called with an invalid type" do
    let(:type) { :invalid_type }

    it "raises an argument error" do
      expect { content }.to raise_error(ArgumentError)
    end
  end
end
