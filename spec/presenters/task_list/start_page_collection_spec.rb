require "rails_helper"

RSpec.describe TaskList::StartPageCollection do
  include ActionView::TestCase::Behavior

  subject(:start_page_collection) { described_class.new(view, application:) }

  let(:application) { create(:legal_aid_application) }

  # Cucumber feature tests are to be used to exercise the bulk of this classes logic
  describe "#render" do
    subject(:page) { Capybara::Node::Simple.new(start_page_collection.render) }

    it "renders expected sections" do
      expect(page)
        .to have_css("ol.govuk-task-list")
        .and have_css("h2.govuk-task-list__section", text: "1. Client and case details")
        .and have_css("h2.govuk-task-list__section", text: "2. Means test")
        .and have_css("h2.govuk-task-list__section", text: "3. Merits")
        .and have_css("h2.govuk-task-list__section", text: "4. Confirm and submit")
    end
  end
end
