require "rails_helper"

RSpec.describe TaskStatus::MakeLink do
  subject(:instance) { described_class.new(application, status_results) }

  let(:application) { create(:application) }
  let(:status_results) { {} }

  describe "#call" do
    subject(:status) { instance.call }

    context "with an incomplete applicant" do
      let(:status_results) { { TaskStatus::Applicants => TaskStatus::ValueObject.new.in_progress! } }

      it { is_expected.to be_cannot_start }
    end

    context "with all client details completed" do
      let(:status_results) { { TaskStatus::Applicants => TaskStatus::ValueObject.new.completed! } }

      it { is_expected.to be_not_started }
    end

    context "with partially completed link section" do
      before { application.update!(linked_application_completed: false) }

      it { is_expected.to be_in_progress }
    end

    context "with completed link section" do
      before { application.update!(linked_application_completed: true) }

      it { is_expected.to be_completed }
    end
  end
end
