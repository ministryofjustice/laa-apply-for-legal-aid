require "rails_helper"

RSpec.describe Feedback, type: :model do
  describe ".after_commit callbacks" do
    context "when a feedback is created" do
      it "fires the dashboard.feedback_created event" do
        feedback = build(:feedback)
        allow(ActiveSupport::Notifications).to receive(:instrument)

        feedback.save!

        expect(ActiveSupport::Notifications).to have_received(:instrument).with(
          "dashboard.feedback_created",
          feedback_id: feedback.reload.id,
        )
      end
    end

    context "when a feedback is updated" do
      it "does not fire the dashboard.feedback_created event" do
        feedback = create(:feedback)
        allow(ActiveSupport::Notifications).to receive(:instrument)

        feedback.update!(satisfaction: :very_satisfied)

        expect(ActiveSupport::Notifications).not_to have_received(:instrument).with(
          "dashboard.feedback_created",
          feedback_id: feedback.id,
        )
      end
    end
  end
end
