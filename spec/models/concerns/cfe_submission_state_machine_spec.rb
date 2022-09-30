require "rails_helper"

module CFE
  RSpec.describe CFESubmissionStateMachine do
    context "with initial state" do
      it "creates an application in initialised state" do
        submission = create :cfe_submission
        expect(submission.initialised?).to be true
      end
    end

    context "with assessment_created! event" do
      subject(:event!) { submission.assessment_created! }

      let(:submission) { create :cfe_submission }

      it "transitions from initialised to assessment_created" do
        expect { event! }.to change(submission, :aasm_state).from("initialised").to("assessment_created")
        expect(submission.assessment_created?).to be true
      end
    end

    context "with applicant_created! event" do
      let(:submission) { create :cfe_submission, aasm_state: start_state }

      context "when starting from proceeding_types_created" do
        let(:start_state) { "proceeding_types_created" }

        it "transitions from proceeding_types_created to applicant_created" do
          expect { submission.applicant_created! }.to change(submission, :aasm_state).from("proceeding_types_created").to("applicant_created")
          expect(submission.applicant_created?).to be true
        end
      end

      context "when starting from assessment_created" do
        let(:start_state) { "assessment_created" }

        it "transitions from assessment_created to applicant_created" do
          expect { submission.applicant_created! }.to change(submission, :aasm_state).from("assessment_created").to("applicant_created")
          expect(submission.applicant_created?).to be true
        end
      end
    end

    context "with proceeding_types_created! event" do
      subject(:event!) { submission.proceeding_types_created! }

      let(:submission) { create :cfe_submission, aasm_state: "assessment_created" }

      it "transitions from assessment_created to proceeding_types_created" do
        expect { event! }.to change(submission, :aasm_state).from("assessment_created").to("proceeding_types_created")
        expect(submission.proceeding_types_created?).to be true
      end
    end

    context "with dependants_created! event" do
      subject(:event!) { submission.dependants_created! }

      let(:submission) { create :cfe_submission, legal_aid_application:, aasm_state: "explicit_remarks_created" }

      context "when passported" do
        let(:legal_aid_application) { create :legal_aid_application, :with_positive_benefit_check_result }

        it "raise InvalidTransition error" do
          expect { event! }.to raise_error AASM::InvalidTransition, /Event 'dependants_created' cannot transition from 'explicit_remarks_created'/
        end
      end

      context "when non_passported" do
        let(:legal_aid_application) { create :legal_aid_application, :with_negative_benefit_check_result }

        it "transitions from explicit_remarks_created to dependants_created" do
          expect { event! }.to change(submission, :aasm_state).from("explicit_remarks_created").to("dependants_created")
          expect(submission.dependants_created?).to be true
        end
      end
    end

    context "with outgoings_created! event" do
      subject(:event!) { submission.outgoings_created! }

      let(:submission) { create :cfe_submission, legal_aid_application:, aasm_state: "dependants_created" }

      context "when passported" do
        let(:legal_aid_application) { create :legal_aid_application, :with_positive_benefit_check_result }

        it "raise InvalidTransition error" do
          expect { event! }.to raise_error AASM::InvalidTransition, /Event 'outgoings_created' cannot transition from 'dependants_created'/
        end
      end

      context "when non_passported" do
        let(:legal_aid_application) { create :legal_aid_application, :with_negative_benefit_check_result }

        it "transitions from properties created to dependants_created" do
          expect { event! }.to change(submission, :aasm_state).from("dependants_created").to("outgoings_created")
          expect(submission.outgoings_created?).to be true
        end
      end
    end

    context "with state_benefits_created! event" do
      subject(:event!) { submission.state_benefits_created! }

      let(:submission) { create :cfe_submission, legal_aid_application:, aasm_state: "outgoings_created" }

      context "when passported" do
        let(:legal_aid_application) { create :legal_aid_application, :with_positive_benefit_check_result }

        it "raise InvalidTransition error" do
          expect { event! }.to raise_error AASM::InvalidTransition, /Event 'state_benefits_created' cannot transition from 'outgoings_created'/
        end
      end

      context "when non_passported" do
        let(:legal_aid_application) { create :legal_aid_application, :with_negative_benefit_check_result }

        it "transitions from properties created to dependants_created" do
          expect { event! }.to change(submission, :aasm_state).from("outgoings_created").to("state_benefits_created")
          expect(submission.state_benefits_created?).to be true
        end
      end
    end

    context "with other_income_created! event" do
      subject(:event!) { submission.other_income_created! }

      let(:submission) { create :cfe_submission, legal_aid_application:, aasm_state: "state_benefits_created" }

      context "when passported" do
        let(:legal_aid_application) { create :legal_aid_application, :with_positive_benefit_check_result }

        it "raise InvalidTransition error" do
          expect { event! }.to raise_error AASM::InvalidTransition, /Event 'other_income_created' cannot transition from 'state_benefits_created'/
        end
      end

      context "when non_passported" do
        let(:legal_aid_application) { create :legal_aid_application, :with_negative_benefit_check_result }

        it "transitions from state_benefits_created to other_income_created" do
          expect { event! }.to change(submission, :aasm_state).from("state_benefits_created").to("other_income_created")
          expect(submission.other_income_created?).to be true
        end
      end
    end

    context "with explicit_remarks_created! event" do
      subject(:event!) { submission.explicit_remarks_created! }

      let(:submission) { create :cfe_submission, legal_aid_application:, aasm_state: "properties_created" }

      context "when passported" do
        let(:legal_aid_application) { create :legal_aid_application, :with_positive_benefit_check_result }

        it "transitions from state_benefits_created to other_income_created" do
          expect { event! }.to change(submission, :aasm_state).from("properties_created").to("explicit_remarks_created")
          expect(submission.explicit_remarks_created?).to be true
        end
      end

      context "when non_passported" do
        let(:legal_aid_application) { create :legal_aid_application, :with_negative_benefit_check_result }

        it "transitions from state_benefits_created to other_income_created" do
          expect { event! }.to change(submission, :aasm_state).from("properties_created").to("explicit_remarks_created")
          expect(submission.explicit_remarks_created?).to be true
        end
      end
    end

    context "with results_obtained! event" do
      subject(:event!) { submission.results_obtained! }

      context "with passported application" do
        let(:legal_aid_application) { create :legal_aid_application, :with_positive_benefit_check_result }
        let(:submission) { create :cfe_submission, legal_aid_application:, aasm_state: "explicit_remarks_created" }

        it "transitions from explicit remarks created created to results obtained" do
          expect { event! }.to change(submission, :aasm_state).from("explicit_remarks_created").to("results_obtained")
          expect(submission.results_obtained?).to be true
        end
      end

      context "with non_passported_application" do
        let(:legal_aid_application) { create :legal_aid_application, :with_negative_benefit_check_result }

        context "with from properties_created state" do
          let(:submission) { create :cfe_submission, legal_aid_application:, aasm_state: "properties_created" }

          it "raise InvalidTransition error" do
            expect { event! }.to raise_error AASM::InvalidTransition, /Event 'results_obtained' cannot transition from 'properties_created'/
          end
        end
      end
    end

    context "with cash_transactions_created! event" do
      let(:event!) { submission.cash_transactions_created! }

      context "with passported application" do
        let(:legal_aid_application) { create :legal_aid_application, :with_positive_benefit_check_result }
        let(:submission) { create :cfe_submission, legal_aid_application:, aasm_state: "explicit_remarks_created" }

        it "raise InvalidTransition error" do
          expect { event! }.to raise_error AASM::InvalidTransition, /Event 'cash_transactions_created' cannot transition from 'explicit_remarks_created'/
        end
      end

      context "with non_passported_application" do
        let(:legal_aid_application) { create :legal_aid_application, :with_negative_benefit_check_result }

        context "when starting from from employments_created state" do
          let(:submission) { create :cfe_submission, legal_aid_application:, aasm_state: "employments_created" }

          it "transitions to expected state" do
            expect { event! }.to change(submission, :aasm_state).from("employments_created").to("cash_transactions_created")
            expect(submission.cash_transactions_created?).to be true
          end
        end

        context "when starting from from regular_transactions_created state" do
          let(:submission) { create :cfe_submission, legal_aid_application:, aasm_state: "regular_transactions_created" }

          it "transitions to expected state" do
            expect { event! }.to change(submission, :aasm_state).from("regular_transactions_created").to("cash_transactions_created")
            expect(submission.cash_transactions_created?).to be true
          end
        end
      end
    end

    context "with regular_transactions_created! event" do
      let(:event!) { submission.regular_transactions_created! }

      context "with passported application" do
        let(:legal_aid_application) { create :legal_aid_application, :with_positive_benefit_check_result }
        let(:submission) { create :cfe_submission, legal_aid_application:, aasm_state: "employments_created" }

        it "raise InvalidTransition error" do
          expect { event! }.to raise_error AASM::InvalidTransition, /Event 'regular_transactions_created' cannot transition from 'employments_created'/
        end
      end

      context "with non_passported_application" do
        let(:legal_aid_application) { create :legal_aid_application, :with_negative_benefit_check_result }

        context "when starting from from employments_created state" do
          let(:submission) { create :cfe_submission, legal_aid_application:, aasm_state: "employments_created" }

          it "transitions to expected state" do
            expect { event! }.to change(submission, :aasm_state).from("employments_created").to("regular_transactions_created")
            expect(submission.regular_transactions_created?).to be true
          end
        end
      end
    end

    context "with fail! event" do
      let(:states) { Submission.aasm.states.map(&:name) - %i[failed results_obtained] }

      it "transitions to failed from all states except failed and results obtained" do
        states.each do |state|
          submission = create :cfe_submission, aasm_state: state
          expect { submission.fail! }.not_to raise_error
          expect(submission.failed?).to be true
        end
      end
    end
  end
end
