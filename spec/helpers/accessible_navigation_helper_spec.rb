require "rails_helper"

RSpec.describe AccessibleNavigationHelper do
  describe "#link_to_accessible" do
    let(:name) { "Start now" }
    let(:path) { "test_path" }
    let(:html_options) { { class: "gov_link" } }

    context "with html options" do
      it "returns the html for a link with an aria-label and other properties" do
        link = link_to_accessible(name, path, html_options)
        expect(link).to eq '<a class="gov_link" aria-label="Start now" href="test_path">Start now</a>'
      end
    end

    context "with suffix" do
      let(:html_options) { { class: "gov_link", suffix: "Application" } }

      it "returns with aria-label containing label name and suffix" do
        link = link_to_accessible(name, path, html_options)
        str = '<a class="gov_link" suffix="Application" aria-label="Start now Application" href="test_path">Start now</a>'
        expect(link).to eq str
      end
    end

    context "with no html options" do
      it "returns the html for a link with an aria-label" do
        link = link_to_accessible(name, path)
        expect(link).to eq '<a aria-label="Start now" href="test_path">Start now</a>'
      end
    end

    context "with block only" do
      it "returns the html for a link without an aria-label" do
        link = link_to_accessible(path) { "Start now" }
        expect(link).to eq '<a href="test_path">Start now</a>'
      end
    end
  end

  describe "#set_accessible_properties" do
    context "with standard html label" do
      it "sets aria-labels using the label name provided" do
        options = set_accessible_properties("name", {})
        expect(options).to eq({ aria: { label: "name" } })
      end
    end

    context "with html label with suffix" do
      it "sets aria-labels using the label name provided" do
        options = set_accessible_properties("Change", { suffix: "First Name" })
        expect(options).to eq({ aria: { label: "Change First Name" }, suffix: "First Name" })
      end
    end

    context "with html label with content tagging" do
      it "sets aria-labels using just the content of the label name provided" do
        options = set_accessible_properties('Start now <svg label="label"></svg>', {})
        expect(options).to eq({ aria: { label: "Start now" } })
      end
    end
  end
end
