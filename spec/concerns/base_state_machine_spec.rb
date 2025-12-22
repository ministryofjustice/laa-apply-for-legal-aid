require "rails_helper"
require "aasm/rspec"

RSpec.describe BaseStateMachine do
  subject(:state_machine) { legal_aid_application.state_machine }

  let(:legal_aid_application) { create(:legal_aid_application, :with_base_state_machine) }

  describe "#check_applicant_details" do
    let(:event) { :check_applicant_details }

    it { is_expected.to transition_from(:entering_applicant_details).to(:checking_applicant_details).on_event(event) }
    it { is_expected.to transition_from(:applicant_details_checked).to(:checking_applicant_details).on_event(event) }
    it { is_expected.to transition_from(:use_ccms).to(:checking_applicant_details).on_event(event) }
    it { is_expected.to transition_from(:overriding_dwp_result).to(:checking_applicant_details).on_event(event) }

    context "when application requires mean testing" do
      before { allow(legal_aid_application).to receive(:non_means_tested?).and_return(false) }

      it { is_expected.not_to transition_from(:provider_entering_merits).to(:checking_applicant_details).on_event(event) }
    end

    context "when application is non_means_tested" do
      before { allow(legal_aid_application).to receive(:non_means_tested?).and_return(true) }

      it { is_expected.not_to transition_from(:provider_entering_merits).to(:checking_applicant_details).on_event(event) }
    end
  end

  describe "#applicant_details_checked" do
    let(:event) { :applicant_details_checked }

    context "without guard" do
      it { is_expected.to transition_from(:checking_applicant_details).to(:applicant_details_checked).on_event(event) }
      it { is_expected.to transition_from(:use_ccms).to(:applicant_details_checked).on_event(event) }
      it { is_expected.to transition_from(:delegated_functions_used).to(:applicant_details_checked).on_event(event) }
      it { is_expected.to transition_from(:overriding_dwp_result).to(:applicant_details_checked).on_event(event) }
    end

    context "when application requires mean testing" do
      before { allow(legal_aid_application).to receive(:non_means_tested?).and_return(false) }

      it { is_expected.not_to transition_from(:provider_entering_merits).to(:applicant_details_checked).on_event(event) }
    end

    context "when application is non_means_tested" do
      before { allow(legal_aid_application).to receive(:non_means_tested?).and_return(true) }

      it { is_expected.not_to transition_from(:provider_entering_merits).to(:applicant_details_checked).on_event(event) }
    end
  end

  describe "#override_dwp_result" do
    let(:event) { :override_dwp_result }

    it { is_expected.to transition_from(:checking_applicant_details).to(:overriding_dwp_result).on_event(event) }
    it { is_expected.to transition_from(:applicant_details_checked).to(:overriding_dwp_result).on_event(event) }
  end

  describe "#provider_enter_merits" do
    let(:event) { :provider_enter_merits }

    context "when application requires mean testing" do
      before { allow(legal_aid_application).to receive(:non_means_tested?).and_return(false) }

      it { is_expected.not_to transition_from(:applicant_details_checked).to(:provider_entering_merits).on_event(event) }
    end

    context "when application is non_means_tested" do
      before { allow(legal_aid_application).to receive(:non_means_tested?).and_return(true) }

      it { is_expected.to transition_from(:applicant_details_checked).to(:provider_entering_merits).on_event(event) }
    end
  end

  describe "#check_merits_answers" do
    let(:event) { :check_merits_answers }

    it { is_expected.to transition_from(:provider_entering_merits).to(:checking_merits_answers).on_event(event) }
    it { is_expected.to transition_from(:submitting_assessment).to(:checking_merits_answers).on_event(event) }
    it { is_expected.to transition_from(:assessment_submitted).to(:checking_merits_answers).on_event(event) }

    context "when application requires mean testing" do
      before { allow(legal_aid_application).to receive(:non_means_tested?).and_return(false) }

      it { is_expected.not_to transition_from(:applicant_details_checked).to(:checking_merits_answers).on_event(event) }
    end

    context "when application is non_means_tested" do
      before { allow(legal_aid_application).to receive(:non_means_tested?).and_return(true) }

      it { is_expected.to transition_from(:applicant_details_checked).to(:checking_merits_answers).on_event(event) }
    end
  end

  describe "#use_ccms" do
    let(:event) { :use_ccms }

    it { is_expected.to transition_from(:initiated).to(:use_ccms).on_event(event, :unknown) }
    it { is_expected.to transition_from(:entering_applicant_details).to(:use_ccms).on_event(:use_ccms, :unknown) }
    it { is_expected.to transition_from(:checking_applicant_details).to(:use_ccms).on_event(:use_ccms, :unknown) }
    it { is_expected.to transition_from(:applicant_details_checked).to(:use_ccms).on_event(event, :unknown) }
    it { is_expected.to transition_from(:delegated_functions_used).to(:use_ccms).on_event(event, :unknown) }
    it { is_expected.to transition_from(:use_ccms).to(:use_ccms).on_event(event, :unknown) }

    it { is_expected.to transition_from(:use_ccms).to(:use_ccms).on_event(event, :no_online_banking) }
    it { is_expected.to transition_from(:use_ccms).to(:use_ccms).on_event(event, :no_applicant_consent) }
    it { is_expected.to transition_from(:use_ccms).to(:use_ccms).on_event(event, :non_passported) }
    it { is_expected.to transition_from(:use_ccms).to(:use_ccms).on_event(event, :offline_accounts) }
    it { is_expected.to transition_from(:use_ccms).to(:use_ccms).on_event(event, :applicant_self_employed) }
    it { is_expected.to transition_from(:use_ccms).to(:use_ccms).on_event(event, :applicant_armed_forces) }
    it { is_expected.to transition_from(:use_ccms).to(:use_ccms).on_event(event, :partner_self_employed) }
    it { is_expected.to transition_from(:use_ccms).to(:use_ccms).on_event(event, :partner_armed_forces) }
  end
end
