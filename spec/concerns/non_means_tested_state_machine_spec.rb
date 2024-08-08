require "rails_helper"
require "aasm/rspec"

RSpec.describe NonMeansTestedStateMachine do
  subject(:state_machine) { legal_aid_application.state_machine }

  let(:legal_aid_application) { create(:legal_aid_application, :with_non_means_tested_state_machine) }

  it { expect(legal_aid_application).not_to be_applicant_entering_means }
  it { expect(legal_aid_application).not_to be_awaiting_applicant }
  it { expect(legal_aid_application).not_to be_provider_assessing_means }
  it { expect(legal_aid_application).not_to be_checking_passported_answers }
  it { expect(legal_aid_application).not_to be_checking_citizen_answers }
  it { expect(legal_aid_application).not_to be_checking_non_passported_means }

  describe "#provider_recording_parental_responsibilities" do
    let(:event) { :provider_recording_parental_responsibilities }

    it { is_expected.to transition_from(:provider_entering_merits).to(:merits_parental_responsibilities).on_event(event) }
    it { is_expected.to transition_from(:merits_parental_responsibilities).to(:merits_parental_responsibilities).on_event(event) }
    it { is_expected.to transition_from(:merits_parental_responsibilities_all_rejected).to(:merits_parental_responsibilities_all_rejected).on_event(event) }
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
end
