require "rails_helper"

RSpec.describe ResultsPanelSelector do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:applicant) { legal_aid_application.applicant }

  before { allow(legal_aid_application).to receive(:cfe_result).and_return(cfe_result) }

  describe ".call" do
    context "when it is eligible, with no restrictions and no policy disregards" do
      let(:cfe_result) { create(:cfe_v6_result, :eligible) }

      it "returns the eligible partial name" do
        expect(described_class.call(legal_aid_application)).to eq "shared/assessment_results/eligible"
      end
    end

    context "when it is partially_eligible with income_contribution no restrictions or disregards" do
      let(:cfe_result) { create(:cfe_v6_result, :partially_eligible_with_income_contribution_required) }

      before do
        allow(legal_aid_application).to receive_messages(has_restrictions?: false, policy_disregards?: false, capital_disregards?: false)
      end

      it "returns the correct income specific partial" do
        expect(described_class.call(legal_aid_application)).to eq "shared/assessment_results/partially_eligible_income"
      end
    end

    context "when it is partially_eligible with capital_contribution no restrictions or disregards" do
      let(:cfe_result) { create(:cfe_v6_result, :partially_eligible_with_capital_contribution_required) }

      before do
        allow(legal_aid_application).to receive_messages(has_restrictions?: false, policy_disregards?: false, capital_disregards?: false)
      end

      it "returns the correct capital specific partial" do
        expect(described_class.call(legal_aid_application)).to eq "shared/assessment_results/partially_eligible_capital"
      end
    end

    context "when it is eligible with no restrictions or disregards, with extra employment information" do
      let(:cfe_result) { create(:cfe_v6_result, :eligible) }

      before do
        allow(legal_aid_application).to receive_messages(has_restrictions?: false, policy_disregards?: false, capital_disregards?: false)
        allow(applicant).to receive(:extra_employment_information?).and_return(true)
      end

      it "returns the correct capital specific partial" do
        expect(described_class.call(legal_aid_application)).to eq "shared/assessment_results/manual_check_required"
      end
    end

    context "when it has income_contribution with no restrictions or disregards, with extra employment information" do
      let(:cfe_result) { create(:cfe_v6_result, :with_income_contribution_required) }

      before do
        allow(legal_aid_application).to receive_messages(has_restrictions?: false, policy_disregards?: false, capital_disregards?: false)
        allow(applicant).to receive(:extra_employment_information?).and_return(true)
      end

      it "returns the income_contribution name" do
        expect(described_class.call(legal_aid_application)).to eq "shared/assessment_results/manual_check_required"
      end
    end

    context "when it is partially_eligible with capital_contribution no restrictions or disregards, with extra employment information" do
      let(:cfe_result) { create(:cfe_v6_result, :partially_eligible_with_capital_contribution_required) }

      before do
        allow(legal_aid_application).to receive_messages(has_restrictions?: false, policy_disregards?: false, capital_disregards?: false)
        allow(applicant).to receive(:extra_employment_information?).and_return(true)
      end

      it "returns the correct capital specific partial" do
        expect(described_class.call(legal_aid_application)).to eq "shared/assessment_results/manual_check_required"
      end
    end

    context "when it is eligible with no restrictions or disregards, with full employment details manually entered by the provider" do
      let(:cfe_result) { create(:cfe_v6_result, :eligible) }

      before do
        allow(legal_aid_application).to receive_messages(has_restrictions?: false, policy_disregards?: false, capital_disregards?: false, full_employment_details: "test details")
      end

      it "returns the correct capital specific partial" do
        expect(described_class.call(legal_aid_application)).to eq "shared/assessment_results/manual_check_required"
      end
    end

    context "when it has income_contribution with no restrictions or disregards, with full employment details manually entered by the provider" do
      let(:cfe_result) { create(:cfe_v6_result, :with_income_contribution_required) }

      before do
        allow(legal_aid_application).to receive_messages(has_restrictions?: false, policy_disregards?: false, capital_disregards?: false, full_employment_details: "test details")
      end

      it "returns the income_contribution name" do
        expect(described_class.call(legal_aid_application)).to eq "shared/assessment_results/manual_check_required"
      end
    end

    context "when it is partially_eligible with capital_contribution no restrictions or disregards, with extra full employment details manually entered by the provider" do
      let(:cfe_result) { create(:cfe_v6_result, :partially_eligible_with_capital_contribution_required) }

      before do
        allow(legal_aid_application).to receive_messages(has_restrictions?: false, policy_disregards?: false, capital_disregards?: false, full_employment_details: "test details")
      end

      it "returns the correct capital specific partial" do
        expect(described_class.call(legal_aid_application)).to eq "shared/assessment_results/manual_check_required"
      end
    end

    context "when it is partially_eligible with no restrictions or capital disregards BUT with policy disregards" do
      let(:cfe_result) { create(:cfe_v6_result, :partially_eligible_with_income_contribution_required) }

      before do
        allow(legal_aid_application).to receive_messages(has_restrictions?: false, policy_disregards?: true, capital_disregards?: false)
      end

      it "returns the correct capital specific partial" do
        expect(described_class.call(legal_aid_application)).to eq "shared/assessment_results/manual_check_required"
      end
    end

    context "when it is partially_eligible with no restrictions or policy disregards BUT with capital disregards" do
      let(:cfe_result) { create(:cfe_v6_result, :partially_eligible_with_income_contribution_required) }

      before do
        allow(legal_aid_application).to receive_messages(has_restrictions?: false, policy_disregards?: false, capital_disregards?: true)
      end

      it "returns the correct capital specific partial" do
        expect(described_class.call(legal_aid_application)).to eq "shared/assessment_results/manual_check_required"
      end
    end
  end
end
