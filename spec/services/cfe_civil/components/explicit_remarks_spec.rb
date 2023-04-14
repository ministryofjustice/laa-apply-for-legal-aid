require "rails_helper"

RSpec.describe CFECivil::Components::ExplicitRemarks do
  subject(:call) { described_class.call(legal_aid_application) }

  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

  context "when there are no remarks to send" do
    it "renders the expected, empty, JSON" do
      expect(call).to eq({
        explicit_remarks: [],
      }.to_json)
    end
  end

  context "when policy_disregards exist" do
    let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_single_policy_disregard) }

    it "renders the expected JSON" do
      expect(call).to eq({
        explicit_remarks: [
          {
            category: "policy_disregards",
            details: %w[vaccine_damage_payments],
          },
        ],
      }.to_json)
    end
  end
end
