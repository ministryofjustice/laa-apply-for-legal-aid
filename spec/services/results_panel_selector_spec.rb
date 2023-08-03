require "rails_helper"

RSpec.describe ResultsPanelSelector do
  let(:legal_aid_application) { create(:legal_aid_application) }

  before { allow(legal_aid_application).to receive(:cfe_result).and_return(cfe_result) }

  describe ".call" do
    describe "V3 results" do
      context "when it is eligible, with no restrictions and no policy disregards" do
        let(:cfe_result) { create(:cfe_v3_result, :eligible) }

        it "returns the eligible partial name" do
          expect(described_class.call(legal_aid_application)).to eq "shared/assessment_results/eligible"
        end
      end

      context "when it has income_contribution_with no restrictions but with disregards" do
        let(:cfe_result) { create(:cfe_v3_result, :with_income_contribution_required) }

        before do
          allow(legal_aid_application).to receive(:has_restrictions?).and_return(false)
          allow(legal_aid_application).to receive(:policy_disregards?).and_return(true)
        end

        it "returns the income_contribution name" do
          expect(described_class.call(legal_aid_application)).to eq "shared/assessment_results/manual_check_required"
        end
      end
    end

    describe "V4 results" do
      context "when it is eligible, with no restrictions and no policy disregards" do
        let(:cfe_result) { create(:cfe_v4_result, :eligible) }

        it "returns the eligible partial name" do
          expect(described_class.call(legal_aid_application)).to eq "shared/assessment_results/eligible"
        end
      end

      context "when it is partially_eligible with income_contribution no restrictions or disregards" do
        let(:cfe_result) { create(:cfe_v4_result, :partially_eligible_with_income_contribution_required) }

        before do
          allow(legal_aid_application).to receive(:has_restrictions?).and_return(false)
          allow(legal_aid_application).to receive(:policy_disregards?).and_return(false)
        end

        it "returns the correct income specific partial" do
          expect(described_class.call(legal_aid_application)).to eq "shared/assessment_results/partially_eligible_income"
        end
      end

      context "when it is partially_eligible with capital_contribution no restrictions or disregards" do
        let(:cfe_result) { create(:cfe_v4_result, :partially_eligible_with_capital_contribution_required) }

        before do
          allow(legal_aid_application).to receive(:has_restrictions?).and_return(false)
          allow(legal_aid_application).to receive(:policy_disregards?).and_return(false)
        end

        it "returns the correct capital specific partial" do
          expect(described_class.call(legal_aid_application)).to eq "shared/assessment_results/partially_eligible_capital"
        end
      end

      context "when it is eligible with no restrictions or disregards, with extra employment information" do
        let(:cfe_result) { create(:cfe_v4_result, :eligible) }

        before do
          allow(legal_aid_application).to receive(:has_restrictions?).and_return(false)
          allow(legal_aid_application).to receive(:policy_disregards?).and_return(false)
          allow(legal_aid_application).to receive(:extra_employment_information?).and_return(true)
        end

        it "returns the correct capital specific partial" do
          expect(described_class.call(legal_aid_application)).to eq "shared/assessment_results/manual_check_required"
        end
      end

      context "when it has income_contribution with no restrictions or disregards, with extra employment information" do
        let(:cfe_result) { create(:cfe_v4_result, :with_income_contribution_required) }

        before do
          allow(legal_aid_application).to receive(:has_restrictions?).and_return(false)
          allow(legal_aid_application).to receive(:policy_disregards?).and_return(true)
          allow(legal_aid_application).to receive(:extra_employment_information?).and_return(true)
        end

        it "returns the income_contribution name" do
          expect(described_class.call(legal_aid_application)).to eq "shared/assessment_results/manual_check_required"
        end
      end

      context "when it is partially_eligible with capital_contribution no restrictions or disregards, with extra employment information" do
        let(:cfe_result) { create(:cfe_v4_result, :partially_eligible_with_capital_contribution_required) }

        before do
          allow(legal_aid_application).to receive(:has_restrictions?).and_return(false)
          allow(legal_aid_application).to receive(:policy_disregards?).and_return(false)
          allow(legal_aid_application).to receive(:extra_employment_information?).and_return(true)
        end

        it "returns the correct capital specific partial" do
          expect(described_class.call(legal_aid_application)).to eq "shared/assessment_results/manual_check_required"
        end
      end
    end

    context "when it is eligible with no restrictions or disregards, with full employment details manually entered by the provider" do
      let(:cfe_result) { create(:cfe_v4_result, :eligible) }

      before do
        allow(legal_aid_application).to receive(:has_restrictions?).and_return(false)
        allow(legal_aid_application).to receive(:policy_disregards?).and_return(false)
        allow(legal_aid_application).to receive(:full_employment_details).and_return("test details")
      end

      it "returns the correct capital specific partial" do
        expect(described_class.call(legal_aid_application)).to eq "shared/assessment_results/manual_check_required"
      end
    end

    context "when it has income_contribution with no restrictions or disregards, with full employment details manually entered by the provider" do
      let(:cfe_result) { create(:cfe_v4_result, :with_income_contribution_required) }

      before do
        allow(legal_aid_application).to receive(:has_restrictions?).and_return(false)
        allow(legal_aid_application).to receive(:policy_disregards?).and_return(true)
        allow(legal_aid_application).to receive(:full_employment_details).and_return("test details")
      end

      it "returns the income_contribution name" do
        expect(described_class.call(legal_aid_application)).to eq "shared/assessment_results/manual_check_required"
      end
    end

    context "when it is partially_eligible with capital_contribution no restrictions or disregards, with extra full employment details manually entered by the provider" do
      let(:cfe_result) { create(:cfe_v4_result, :partially_eligible_with_capital_contribution_required) }

      before do
        allow(legal_aid_application).to receive(:has_restrictions?).and_return(false)
        allow(legal_aid_application).to receive(:policy_disregards?).and_return(false)
        allow(legal_aid_application).to receive(:full_employment_details).and_return("test details")
      end

      it "returns the correct capital specific partial" do
        expect(described_class.call(legal_aid_application)).to eq "shared/assessment_results/manual_check_required"
      end
    end
  end
end
