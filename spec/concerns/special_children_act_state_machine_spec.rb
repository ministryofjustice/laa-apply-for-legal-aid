require "rails_helper"
require "aasm/rspec"

RSpec.describe SpecialChildrenActStateMachine do
  subject(:state_machine) { legal_aid_application.state_machine }

  let(:legal_aid_application) { create(:legal_aid_application, :with_sca_state_machine) }

  it { expect(legal_aid_application).not_to be_citizen_entering_means }
  it { expect(legal_aid_application).not_to be_awaiting_applicant }
  it { expect(legal_aid_application).not_to be_provider_assessing_means }
  it { expect(legal_aid_application).not_to be_checking_passported_answers }
  it { expect(legal_aid_application).not_to be_checking_citizen_answers }
  it { expect(legal_aid_application).not_to be_checking_non_passported_means }

  describe ".case_add_requestor" do
    it { expect(state_machine.case_add_requestor).to eq CCMS::Requestors::SpecialChildrenActCaseAddRequestor }
  end

  describe "#provider_recording_parental_responsibilities" do
    let(:event) { :provider_recording_parental_responsibilities }

    it { is_expected.to transition_from(:provider_entering_merits).to(:merits_parental_responsibilities).on_event(event) }
    it { is_expected.to transition_from(:merits_parental_responsibilities).to(:merits_parental_responsibilities).on_event(event) }
    it { is_expected.to transition_from(:merits_parental_responsibilities_all_rejected).to(:merits_parental_responsibilities_all_rejected).on_event(event) }
    it { is_expected.to transition_from(:checking_merits_answers).to(:merits_parental_responsibilities).on_event(event) }
  end

  describe "#rejected_all_parental_responsibilities" do
    let(:event) { :rejected_all_parental_responsibilities }

    it { is_expected.to transition_from(:merits_parental_responsibilities).to(:merits_parental_responsibilities_all_rejected).on_event(event) }
    it { is_expected.to transition_from(:merits_parental_responsibilities_all_rejected).to(:merits_parental_responsibilities_all_rejected).on_event(event) }
  end

  describe "#provider_enter_merits" do
    let(:event) { :provider_enter_merits }

    before { allow(legal_aid_application).to receive(:non_means_tested?).and_return(true) }

    it { is_expected.to transition_from(:merits_parental_responsibilities_all_rejected).to(:provider_entering_merits).on_event(event) }
    it { is_expected.to transition_from(:merits_parental_responsibilities).to(:provider_entering_merits).on_event(event) }
  end

  describe "#check_merits_answers" do
    let(:event) { :check_merits_answers }

    before { allow(legal_aid_application).to receive(:non_means_tested?).and_return(true) }

    it { is_expected.to transition_from(:applicant_details_checked).to(:checking_merits_answers).on_event(event) }
    it { is_expected.to transition_from(:merits_parental_responsibilities_all_rejected).to(:checking_merits_answers).on_event(event) }
    it { is_expected.to transition_from(:merits_parental_responsibilities).to(:checking_merits_answers).on_event(event) }
  end

  describe ".submit_to_datastore?" do
    subject(:submit_to_datastore) { state_machine.submit_to_datastore? }

    before do
      allow(Setting).to receive(:enable_datastore_submission?).and_return(enable_datastore_submission)
    end

    let(:enable_datastore_submission) { true }

    context "when datastore submissions are not enabled" do
      let(:enable_datastore_submission) { false }

      it { is_expected.to be false }
    end

    context "when datastore submissions are enabled" do
      it { is_expected.to be true }

      context "and on production" do
        before { allow(HostEnv).to receive(:environment).and_return(:production) }

        it { is_expected.to be false }
      end
    end
  end
end
