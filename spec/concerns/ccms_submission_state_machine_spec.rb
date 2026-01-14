require "rails_helper"
require "aasm/rspec"

RSpec.describe CCMSSubmissionStateMachine do
  subject(:state_machine) { ccms_submission }

  describe "#obtain_case_ref" do
    let(:event) { :obtain_case_ref }

    context "when the application has a lead application" do
      let(:ccms_submission) { create(:ccms_submission, :initialised, legal_aid_application:) }
      let(:legal_aid_application) { create(:legal_aid_application, :with_base_state_machine, linked_application_completed:) }
      let(:lead_application) { create(:legal_aid_application) }

      describe "when the lead application submission has not started" do
        let(:linked_application_completed) { true }

        before do
          create(:linked_application, lead_application:, associated_application: legal_aid_application, link_type_code: "FC_LEAD")
        end

        it { is_expected.to transition_from(:initialised).to(:lead_application_pending).on_event(event) }
      end

      describe "when the lead application submission is still in progress" do
        let(:linked_application_completed) { false }

        before do
          create(:linked_application, lead_application:, associated_application: legal_aid_application, link_type_code: "FC_LEAD")
          create(:ccms_submission, :initialised, legal_aid_application: lead_application)
        end

        it { is_expected.to transition_from(:initialised).to(:lead_application_pending).on_event(event) }
      end

      describe "when the lead application submission has completed" do
        let(:linked_application_completed) { true }

        before do
          create(:linked_application, lead_application:, associated_application: legal_aid_application, link_type_code: "FC_LEAD")
          create(:ccms_submission, :case_completed, legal_aid_application: lead_application)
        end

        it { is_expected.to transition_from(:initialised).to(:case_ref_obtained).on_event(event) }
      end
    end
  end

  describe "#restart_linked_application" do
    let(:event) { :restart_linked_application }
    let(:ccms_submission) { create(:ccms_submission, :lead_application_pending, legal_aid_application:) }
    let(:legal_aid_application) { create(:legal_aid_application, :with_base_state_machine, linked_application_completed:) }
    let(:lead_application) { create(:legal_aid_application) }

    describe "when the lead application submission is still in progress" do
      let(:linked_application_completed) { false }

      before do
        create(:linked_application, lead_application:, associated_application: legal_aid_application, link_type_code: "FC_LEAD")
        create(:ccms_submission, :initialised, legal_aid_application: lead_application)
      end

      it { is_expected.not_to transition_from(:lead_application_pending).on_event(event) }
    end

    describe "when the lead application submission has completed" do
      let(:linked_application_completed) { true }

      before do
        create(:linked_application, lead_application:, associated_application: legal_aid_application, link_type_code: "FC_LEAD")
        create(:ccms_submission, :case_completed, legal_aid_application: lead_application)
      end

      it { is_expected.to transition_from(:lead_application_pending).to(:case_ref_obtained).on_event(event) }
    end
  end

  describe "#complete" do
    let(:event) { :complete }
    let(:legal_aid_application) { create(:legal_aid_application, :with_base_state_machine, :submitting_assessment) }
    let(:ccms_submission) { create(:ccms_submission, :case_created, legal_aid_application:) }

    context "when the submissions application is not a lead" do
      it { is_expected.to transition_from(:case_created).to(:completed).on_event(event) }
    end

    context "when the submissions application is a lead with associated applications marked as pending" do
      let(:associated_application) { create(:legal_aid_application, :with_base_state_machine) }
      let(:associated_submission) { create(:ccms_submission, :lead_application_pending, legal_aid_application: associated_application) }

      before do
        create(:linked_application, lead_application: legal_aid_application, associated_application:, link_type_code: "FC_LEAD")
        allow(associated_submission).to receive(:restart_linked_application!)
      end

      it "changes the state of the lead submission and calls restart_linked_application on associated applications" do
        expect(associated_submission.aasm_state).to eq "lead_application_pending"
        expect(state_machine).to transition_from(:case_created).to(:completed).on_event(event)
        expect(associated_submission.reload.aasm_state).to eq "case_ref_obtained"
      end
    end

    context "when the submissions application is a lead with associated applications that have not been marked as pending" do
      let(:associated_application) { create(:legal_aid_application, :with_base_state_machine) }
      let(:associated_submission) { create(:ccms_submission, :initialised, legal_aid_application: associated_application) }

      before do
        create(:linked_application, lead_application: legal_aid_application, associated_application:, link_type_code: "FC_LEAD")
        allow(associated_submission).to receive(:restart_linked_application!)
      end

      it "changes the state of the lead submission and does not call restart_linked_application on the associated application" do
        expect(associated_submission.aasm_state).to eq "initialised"
        expect(state_machine).to transition_from(:case_created).to(:completed).on_event(event)
        expect(associated_submission.reload.aasm_state).to eq "initialised"
      end
    end

    context "when the submissions application is a lead with associated applications that is still in progress" do
      let(:associated_application) { create(:legal_aid_application, :with_base_state_machine) }

      before do
        create(:linked_application, lead_application: legal_aid_application, associated_application:, link_type_code: "FC_LEAD")
      end

      it "changes the state of the lead submission and does not attempt to call restart_linked_application on the associated application" do
        expect(state_machine).to transition_from(:case_created).to(:completed).on_event(event)
      end
    end
  end
end
