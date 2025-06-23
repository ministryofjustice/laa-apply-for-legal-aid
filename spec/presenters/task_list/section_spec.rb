require "rails_helper"

RSpec.describe TaskList::Section do
  let(:presenter) { described_class.new(application, **args) }
  let(:application) { create(:legal_aid_application) }

  let(:args) do
    {
      name: :client_and_case_details,
      tasks:,
      index: 1,
    }
  end

  let(:tasks) do
    {
      applicants: true,
    }
  end

  describe "#render" do
    subject(:page) { Capybara::Node::Simple.new(render) }

    let(:render) { presenter.render }

    context "with defaults" do
      it "renders a section header with 1-based index number" do
        expect(page).to have_css("h2.govuk-task-list__section", text: "1. Client and case details")
      end

      it "renders a section body of task list items" do
        expect(page)
          .to have_css("li", text: "Client details")
          .and have_css(".govuk-task-list__status", text: "Not started")
      end

      it "renders a status tag of a certain color" do
        expect(page)
          .to have_css(".govuk-tag--blue", text: "Not started")
      end
    end

    context "with body override supplied" do
      let(:args) do
        {
          name: :client_and_case_details,
          tasks:,
          index: 1,
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

    context "with no index supplied" do
      let(:args) do
        {
          name: :client_and_case_details,
          tasks:,
          index: nil,
        }
      end

      it "render section header without an index number" do
        pp render
        expect(page)
          .to have_css("h2.govuk-task-list__section", text: "Client and case details")
          .and have_no_css("h2", text: "1")
      end
    end

    context "with conditionally render task list items" do
      let(:tasks) do
        {
          applicants: ->(_application) { display },
        }
      end

      context "with callable logic returning true" do
        let(:display) { true }

        it "renders the task list item" do
          expect(page)
            .to have_css("li", text: "Client details")
            .and have_css(".govuk-task-list__status", text: "Not started")
        end
      end

      context "with callable logic returning false" do
        let(:display) { false }

        it "does NOT render the task list item" do
          expect(page)
            .to have_no_css("li", text: "Client details")
            .and have_no_css(".govuk-task-list__status", text: "Not started")
        end
      end
    end
  end
end
