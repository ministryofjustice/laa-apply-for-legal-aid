require "rails_helper"

RSpec.describe Flow::Steps::ProviderMeans::RemoveStateBenefitsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:transaction) do
    create(:regular_transaction,
           transaction_type: create(:transaction_type, :benefits),
           legal_aid_application:,
           description: "Test removal of state benefit",
           owner_id: legal_aid_application.applicant.id,
           owner_type: "Applicant")
  end

  describe "#path" do
    subject { described_class.path.call(legal_aid_application, transaction) }

    it { is_expected.to eql providers_legal_aid_application_means_remove_state_benefit_path(legal_aid_application, transaction) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application, applicant_has_any_state_benefits) }

    context "when applicant_has_any_state_benefits is sent as true" do
      let(:applicant_has_any_state_benefits) { true }

      it { is_expected.to eq :add_other_state_benefits }
    end

    context "when applicant_has_any_state_benefits is sent as false" do
      let(:applicant_has_any_state_benefits) { false }

      it { is_expected.to eq :receives_state_benefits }
    end
  end
end
