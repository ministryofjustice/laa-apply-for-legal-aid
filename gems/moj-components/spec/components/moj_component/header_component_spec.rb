require "rails_helper"

RSpec.describe MojComponent::HeaderComponent, type: :component do
  let(:content) do
    render_inline(described_class.new(organisation_name:, url:, new_tab:)) do |header|
      header.with_navigation_item(text: "Nav item 1", href: "nav1-url")
      header.with_navigation_item(text: "Nav item 2", href: "nav2-url")
    end
  end

  let(:organisation_name) { "Organisation name" }
  let(:url) { "heading_url" }
  let(:new_tab) { false }

  context "when header is called with everything" do
    it "renders the organisation link and navigation items" do
      expect(content)
        .to have_link("Organisation name",
                      href: "heading_url",
                      class: "govuk-link moj-header__link moj-header__link--organisation-name")
        .and have_link("Nav item 1",
                       href: "nav1-url",
                       class: "moj-header__navigation-link")
        .and have_link("Nav item 2",
                       href: "nav2-url",
                       class: "moj-header__navigation-link")
    end
  end

  context "when header is called without nav items" do
    let(:content) do
      render_inline(described_class.new(organisation_name:, url:, new_tab:))
    end

    it "does not render any nav item markup" do
      expect(content)
        .to have_no_css("nav.moj-header__navigation")
    end
  end

  context "when new_tab is true" do
    let(:new_tab) { true }

    it "sets target and rel attributes on organisation link" do
      expect(content)
        .to have_css(
          "a.moj-header__link.moj-header__link--organisation-name[target='_blank'][rel*='noopener']",
          text: "Organisation name",
        )
    end
  end

  context "when a nav item is current" do
    let(:content) do
      render_inline(described_class.new(organisation_name:, url:, new_tab:)) do |header|
        header.with_navigation_item(text: "Nav item 1", href: "nav1-url", current: true)
        header.with_navigation_item(text: "Nav item 2", href: "nav2-url")
      end
    end

    it "adds aria-current on the current item link" do
      expect(content)
        .to have_css("a.moj-header__navigation-link[aria-current='page']", text: "Nav item 1")
    end
  end

  context "when passing extra HTML options to a nav item" do
    let(:content) do
      render_inline(described_class.new(organisation_name:, url:, new_tab:)) do |header|
        header.with_navigation_item(text: "Nav item", href: "nav1-url", options: { id: "first-item", data: { test: "test" } })
      end
    end

    it "applies the options to the link" do
      expect(content)
        .to have_css("a.moj-header__navigation-link#first-item[data-test='test']", text: "Nav item")
    end
  end
end
