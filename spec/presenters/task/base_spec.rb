require "rails_helper"

RSpec.describe Task::Base do
  let(:application) { create(:legal_aid_application) }

  describe ".build" do
    context "with an existing named class" do
      it "builds an instance of the named class" do
        task = described_class.build(application, "applicants")

        expect(task).to be_instance_of(Task::Applicants)
        expect(task.application).to eq(application)
      end
    end

    context "without an existing named class" do
      it "builds an instance of the base class" do
        task = described_class.build(application, "foobar")

        expect(task).to be_a(described_class)
        expect(task.application).to eq(application)
      end
    end
  end

  describe "#render" do
    context "when instantiated with an existing task status class" do
      let(:page) { Capybara::Node::Simple.new(instance.render) }
      let(:instance) { described_class.build(application, "applicants") }

      context "when status allows links to be enabled" do
        before { allow(instance.status).to receive(:enabled?).and_return(true) }

        it "renders a task link" do
          expect(page)
            .to have_css(".govuk-task-list__item.govuk-task-list__item--with-link")
            .and have_css(".app-task-list__task-name.govuk-task-list__name-and-hint", text: "Client details")
            .and have_css("a.govuk-link.govuk-task-list__link", text: "Client details")
        end
      end

      context "when status does not allows link to be enabled" do
        before { allow(instance.status).to receive(:enabled?).and_return(false) }

        it "renders a task name (no link) and status tag" do
          expect(page)
            .to have_css(".app-task-list__task-name.govuk-task-list__name-and-hint", text: "Client details")
            .and have_no_css("a.govuk-link")
            .and have_no_link("Client details")
        end
      end

      it "renders status tag with no colour for cannot_start" do
        allow(instance).to receive(:status).and_return(TaskStatus::ValueObject.new.cannot_start!)

        expect(page)
          .to have_css(".govuk-task-list__status", text: "Cannot start yet")
          .and have_no_css(".govuk-tag")
      end

      it "renders status tag with grey colour for not_ready" do
        allow(instance).to receive(:status).and_return(TaskStatus::ValueObject.new.not_ready!)

        expect(page)
          .to have_css(".govuk-task-list__status .govuk-tag.govuk-tag--grey", text: "Not ready")
      end

      it "renders status tag with blue colour for not_started" do
        allow(instance).to receive(:status).and_return(TaskStatus::ValueObject.new.not_started!)

        expect(page)
          .to have_css(".govuk-task-list__status .govuk-tag.govuk-tag--blue", text: "Not started")
      end

      it "renders status tag with light blue colour for in_progress" do
        allow(instance).to receive(:status).and_return(TaskStatus::ValueObject.new.in_progress!)

        expect(page)
          .to have_css(".govuk-task-list__status .govuk-tag.govuk-tag--light-blue", text: "In progress")
      end

      it "renders status tag with no colour for completed" do
        allow(instance).to receive(:status).and_return(TaskStatus::ValueObject.new.completed!)

        expect(page)
          .to have_css(".govuk-task-list__status", text: "Completed")
          .and have_no_css(".govuk-tag")
      end
    end

    context "when instantiated without an existing task status class" do
      let(:instance) { described_class.build(application, "foobar") }

      it "raises error" do
        expect { instance.render }.to raise_error("TaskStatus::Foobar not implemented! Follow task list pattern or overide in subclass.")
      end
    end
  end

  describe "#path" do
    context "when instantiated by a sub class" do
      let(:instance) { described_class.build(application, "applicants") }

      it "returns the result of calling path as defined in the subclass" do
        expect(instance.path).to be_instance_of(String)
      end
    end

    context "when instantiated by the base class" do
      let(:instance) { described_class.build(application, "foobar") }

      it "raises error" do
        expect { instance.path }.to raise_error("Task::Foobar.path not implemented. Implement in subclass.")
      end
    end
  end

  describe "#status" do
    context "when instantiated with an existing task status class" do
      let(:instance) { described_class.build(application, "applicants") }

      it "returns task status value object" do
        expect(instance.status).to be_instance_of(TaskStatus::ValueObject)
      end
    end

    context "when instantiated without an existing task status class" do
      let(:instance) { described_class.build(application, "foobar") }

      it "raises error" do
        expect { instance.status }.to raise_error("TaskStatus::Foobar not implemented! Follow task list pattern or overide in subclass.")
      end
    end
  end
end
