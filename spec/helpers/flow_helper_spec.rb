require "rails_helper"

RSpec.describe FlowHelper do
  describe "#next_action_buttons_with_form" do
    it "wraps next_action_buttons inside a form_with" do
      html = helper.next_action_buttons_with_form(url: "/test-path")
      expect(html).to have_css("form[action=\"/test-path\"]")
    end

    it "includes a continue button by default" do
      html = helper.next_action_buttons_with_form(url: "/test-path")
      expect(html).to have_button("Save and continue")
    end

    it "can remove continue button" do
      html = helper.next_action_buttons_with_form(url: "/test-path", show_continue: false)
      expect(html).to have_no_button("Save and continue")
    end

    it "can inverse the continue button colours" do
      html = helper.next_action_buttons_with_form(
        url: "/test-path",
        inverse_continue: true,
      )
      expect(html).to have_button("Save and continue", class: "govuk-button--inverse")
    end

    it "can override the continue button text" do
      html = helper.next_action_buttons_with_form(
        url: "/test-path",
        continue_button_text: "Proceed",
      )
      expect(html).to have_button("Proceed")
    end

    it "does not include a draft button by default" do
      html = helper.next_action_buttons_with_form(url: "/test-path")
      expect(html).to have_no_button("Save and come back later")
    end

    it "shows the draft button when show_draft is true" do
      html = helper.next_action_buttons_with_form(url: "/test-path", show_draft: true)
      expect(html).to have_button("Save and come back later")
    end

    it "can override the draft button text" do
      html = helper.next_action_buttons_with_form(
        url: "/test-path",
        show_draft: true,
        draft_button_text: "Save and exit",
      )
      expect(html).to have_button("Save and exit")
    end

    it "includes an additional link when text and url are given" do
      html = helper.next_action_buttons_with_form(
        url: "/test-path",
        additional_link: { text: "Cancel", url: "/cancel" },
      )
      expect(html).to have_link("Cancel", href: "/cancel")
    end

    it "places buttons and links inside a govuk-button-group" do
      html = helper.next_action_buttons_with_form(url: "/test-path")
      expect(html).to have_css("div", class: "govuk-button-group")
    end

    it "merges container_class into the default govuk-button-group" do
      html = helper.next_action_buttons_with_form(
        url: "/test-path",
        container_class: "extra-class",
      )
      expect(html).to have_css("div", class: "govuk-button-group extra-class")
    end
  end
end
