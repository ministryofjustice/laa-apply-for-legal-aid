require "rails_helper"

RSpec.describe Flow::Steps::ProviderMeansStateBenefits::ReceivesStateBenefitsStep, type: :request do
  let(:application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(application) }

    it { is_expected.to eq providers_legal_aid_application_means_receives_state_benefits_path(application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(application, receives_state_benefits) }

    context "when applicant receives state benefits" do
      let(:receives_state_benefits) { true }

      it { is_expected.to eq :state_benefits }
    end

    context "when applicant does not receive state benefits" do
      let(:receives_state_benefits) { false }

      it { is_expected.to eq :regular_incomes }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(application) }

    context "when the provider says benefits are received" do
      let(:application) { create(:legal_aid_application, applicant:) }
      let(:applicant) { create(:applicant, receives_state_benefits:) }
      let(:receives_state_benefits) { true }

      before do
        create(:regular_transaction,
               transaction_type: create(:transaction_type, :benefits),
               legal_aid_application: application,
               description: "Test state benefit",
               owner_id: application.applicant.id,
               owner_type: "Applicant")
      end

      it { is_expected.to eq :add_other_state_benefits }
    end

    context "when the provider says benefits are received but has not yet added it" do
      let(:application) { create(:legal_aid_application, applicant:) }
      let(:applicant) { create(:applicant, receives_state_benefits:) }
      let(:receives_state_benefits) { true }

      it { is_expected.to eq :state_benefits }
    end

    context "when the provider says no benefits received" do
      let(:application) { create(:legal_aid_application, applicant:) }
      let(:applicant) { create(:applicant, receives_state_benefits:) }
      let(:receives_state_benefits) { false }

      it { is_expected.to eq :check_income_answers }
    end
  end
end
