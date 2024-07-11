require "rails_helper"

RSpec.describe Flow::Steps::Partner::AddOtherStateBenefitsStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_partners_add_other_state_benefits_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application, add_other_state_benefits) }

    context "when the provider has chosen to add other state benefits" do
      let(:add_other_state_benefits) { true }

      it { is_expected.to eq :partner_state_benefits }
    end

    context "when the provider has chosen not to add other state benefits" do
      let(:add_other_state_benefits) { false }

      it { is_expected.to eq :partner_regular_incomes }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(legal_aid_application, add_other_state_benefits) }

    context "when the provider has chosen to add other state benefits" do
      let(:add_other_state_benefits) { true }

      it { is_expected.to eq :partner_state_benefits }
    end

    context "when the provider has chosen not to add other state benefits" do
      let(:add_other_state_benefits) { false }

      it { is_expected.to eq :check_income_answers }
    end
  end
end
