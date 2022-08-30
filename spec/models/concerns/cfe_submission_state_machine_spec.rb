require "rails_helper"

module CFE
  RSpec.describe CFESubmissionStateMachine do
    context "with initial state" do
      it "creates an application in initialised state" do
        submission = create(:cfe_submission)
        expect(submission.initialised?).to be true
      end
    end

    context "with assessment_created! event" do
      subject(:event!) { submission.assessment_created! }

      let(:submission) { create(:cfe_submission) }

      it "transitions from initialised to assessment_created" do
        expect { event! }.to change(submission, :aasm_state).from("initialised").to("assessment_created")
        expect(submission.assessment_created?).to be true
      end
    end

    context "when in_progress! event called" do
      let(:submission) { create(:cfe_submission, aasm_state: start_state) }

      before { submission.in_progress! }

      context "when state is assessment_created" do
        let(:start_state) { "assessment_created" }

        it "transitions to in_progress" do
          expect(submission.in_progress?).to be true
        end
      end

      context "when state is in_progress" do
        let(:start_state) { "in_progress" }

        it "transitions to in_progress" do
          expect(submission.in_progress?).to be true
        end
      end
    end

    context "with results_obtained! event" do
      let(:submission) { create(:cfe_submission, aasm_state: "in_progress") }

      before { submission.results_obtained! }

      it "transitions to results_obtained" do
        expect(submission.results_obtained?).to be true
      end
    end

    context "with fail! event" do
      let(:states) { Submission.aasm.states.map(&:name) - %i[failed results_obtained] }

      it "transitions to failed from all states except failed and results obtained" do
        states.each do |state|
          submission = create(:cfe_submission, aasm_state: state)
          expect { submission.fail! }.not_to raise_error
          expect(submission.failed?).to be true
        end
      end
    end
  end
end
