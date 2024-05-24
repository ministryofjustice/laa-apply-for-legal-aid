require "rails_helper"

RSpec.describe Flow::Steps::ProviderMeansStateBenefits::StateBenefitsStep, type: :request do
  let(:application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(application) }

    it { is_expected.to eq new_providers_legal_aid_application_means_state_benefit_path(application) }
  end

  describe "#forward" do
    subject { described_class.forward }

    context "when applicant receives state benefits" do
      let(:receives_state_benefits) { true }

      it { is_expected.to eq :add_other_state_benefits }
    end
  end
end
