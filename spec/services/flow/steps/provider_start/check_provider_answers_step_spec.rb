require "rails_helper"

RSpec.describe Flow::Steps::ProviderStart::CheckProviderAnswersStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application, applicant:) }
  let(:applicant) { create(:applicant, age_for_means_test_purposes:, national_insurance_number:) }
  let(:age_for_means_test_purposes) { 18 }
  let(:national_insurance_number) { "JC123456B" }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_check_provider_answers_path(legal_aid_application) }
  end

  describe "#forward" do
    subject(:forward_step) { described_class.forward.call(legal_aid_application) }

    context "when the applicant is under 18" do
      let(:age_for_means_test_purposes) { 17 }

      it { is_expected.to eq :confirm_non_means_tested_applications }

      it "sets the state machine" do
        forward_step
        expect(legal_aid_application.state_machine.type).to eq "NonMeansTestedStateMachine"
      end
    end

    context "when applicant has national insurance number" do
      it { is_expected.to eq :check_benefits }
    end

    context "when applicant does not have national insurance number" do
      let(:national_insurance_number) { "" }

      it { is_expected.to eq :no_national_insurance_numbers }
    end

    context "when the application has an SCA proceeding" do
      let(:legal_aid_application) do
        create(:legal_aid_application,
               :with_proceedings,
               explicit_proceedings: %i[pb003],
               set_lead_proceeding: :pb003,
               applicant:)
      end

      it { is_expected.to eq :confirm_non_means_tested_applications }

      it "sets the state machine" do
        forward_step
        expect(legal_aid_application.state_machine.type).to eq "SpecialChildrenActStateMachine"
      end
    end

    context "when the application has a non means tested PLF proceeding" do
      let(:legal_aid_application) do
        create(:legal_aid_application,
               :with_proceedings,
               explicit_proceedings: %i[pbm40],
               set_lead_proceeding: :pbm40,
               applicant:)
      end

      it { is_expected.to eq :confirm_non_means_tested_applications }
    end
  end
end
