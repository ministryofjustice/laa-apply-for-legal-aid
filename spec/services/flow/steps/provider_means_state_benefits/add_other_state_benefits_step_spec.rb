require "rails_helper"

RSpec.describe Flow::Steps::ProviderMeansStateBenefits::AddOtherStateBenefitsStep, type: :request do
  let(:application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(application) }

    it { is_expected.to eq providers_legal_aid_application_means_add_other_state_benefits_path(application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(application, add_other_state_benefits) }

    context "when applicant receives more than one state benefit" do
      let(:add_other_state_benefits) { true }

      it { is_expected.to eq :state_benefits }
    end

    context "when applicant receives only one state benefits" do
      let(:add_other_state_benefits) { false }

      it { is_expected.to eq :regular_incomes }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(application, add_other_state_benefits) }

    context "when applicant receives more than one state benefit" do
      let(:add_other_state_benefits) { true }

      it { is_expected.to eq :state_benefits }
    end

    context "when applicant receives only one state benefit" do
      let(:add_other_state_benefits) { false }

      it { is_expected.to eq :check_income_answers }
    end
  end
end
