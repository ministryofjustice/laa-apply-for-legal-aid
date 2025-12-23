require "rails_helper"

RSpec.describe MojComponent::SubNavigationComponent, type: :component do
  context "when sub navigation component is called" do
    let(:content) do
      render_inline described_class.new do |component|
        component.with_navigation_item(text: "Nav item 1")
      end
    end

    context "with one nav item" do
      it "renders only one" do
        expect(content).to have_css("li.moj-sub-navigation__item > a.moj-sub-navigation__link", text: "Nav item 1")
      end
    end

    context "with multiple nav items" do
      let(:content) do
        render_inline described_class.new do |component|
          component.with_navigation_item(text: "Nav item 1")
          component.with_navigation_item(text: "Nav item 2")
        end
      end

      it "renders each one in order" do
        expect(content).to have_css("li.moj-sub-navigation__item > a.moj-sub-navigation__link", text: "Nav item 1")
        expect(content).to have_css("li.moj-sub-navigation__item > a.moj-sub-navigation__link", text: "Nav item 2")
      end
    end

    context "without href" do
      it "defaults to #" do
        expect(content).to have_link("Nav item 1", href: "#")
      end
    end

    context "with hrefs" do
      subject(:content) do
        render_inline described_class.new do |component|
          component.with_navigation_item(text: "Nav item 1", href: "test-url-1")
          component.with_navigation_item(text: "Nav item 2", href: "test-url-2")
        end
      end

      it "renders hrefs" do
        expect(content).to have_link("Nav item 1", href: "test-url-1")
        expect(content).to have_link("Nav item 2", href: "test-url-2")
      end
    end

    context "without current set" do
      it "doesn't have aria-current" do
        expect(content).to have_no_css("a[aria-current]")
      end
    end

    context "with current set to true" do
      subject(:content) do
        render_inline described_class.new do |component|
          component.with_navigation_item(text: "Nav item 1", href: "test-url-1", current: true)
        end
      end

      it "has aria-current" do
        expect(content).to have_css("a[aria-current]")
      end
    end
  end
end
