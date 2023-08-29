require "rails_helper"

RSpec.describe LegalAidApplications::HasEvidenceOfBenefitForm do
  subject(:described_form) { described_class.new(params.merge(model: dwp_override)) }

  let(:dwp_override) { create(:dwp_override, passporting_benefit: "Valid state benefit") }
  let(:has_evidence_of_benefit) { true }
  let(:params) do
    {
      has_evidence_of_benefit:,
    }
  end

  describe "valid?" do
    it "returns true when validations pass" do
      expect(described_form).to be_valid
    end

    context "when invalid" do
      let(:has_evidence_of_benefit) { nil }

      it "returns false when validations fail" do
        expect(described_form).not_to be_valid
      end
    end
  end
end
