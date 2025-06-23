require "rails_helper"

RSpec.describe TaskList::Subsection do
  let(:presenter) { described_class.new(application, **args) }
  let(:application) { create(:legal_aid_application) }

  let(:args) do
    {
      name: :means_assessment,
      sub_name: :financial_information,
      tasks: {},
      index: 2,
    }
  end

  describe "#render" do
    subject(:page) { Capybara::Node::Simple.new(render) }

    let(:render) { presenter.render }

    context "with defaults" do
      it "renders a section header with 1-based index number" do
        expect(page).to have_css("h2.govuk-task-list__section", text: "2. Means test")
      end

      it "renders a subsection header" do
        expect(page).to have_css("h3.govuk-task-list__section", text: "Financial information")
      end
    end

    context "with body override supplied" do
      let(:args) do
        {
          name: :means_assessment,
          sub_name: :financial_information,
          tasks: {},
          index: 2,
          body_override: "Display this text instead of a task list",
        }
      end

      it "renders body_override text instead of a task list" do
        expect(page).to have_content("Display this text instead of a task list")
      end

      it "does not render the task list" do
        expect(page).to have_no_css(".govuk-task-list__items")
      end
    end

    context "with display_section_header set to false" do
      let(:args) do
        {
          name: :means_assessment,
          sub_name: :financial_information,
          tasks: {},
          index: 2,
          display_section_header: false,
        }
      end

      it "does NOT render the section header" do
        expect(page).to have_no_css("h2")
      end

      it "renders the subsection header" do
        expect(page).to have_css("h3.govuk-task-list__section", text: "Financial information")
      end

      it "renders the section body with task list items", skip: "TODO: once means task list items in place" do
        expect(page)
          .to have_css("li", text: "Employment income")
          .and have_css(".govuk-task-list__status", text: "Not started")
      end
    end

    context "with no index supplied" do
      let(:args) do
        {
          name: :means_assessment,
          sub_name: :financial_information,
          tasks: {},
          index: nil,
        }
      end

      it "render section header without an index number" do
        expect(page)
          .to have_css("h2.govuk-task-list__section", text: "Means test")
          .and have_no_css("h2", text: "1")
      end
    end
  end
end
