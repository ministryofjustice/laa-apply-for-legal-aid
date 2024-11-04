require "rails_helper"

RSpec.describe Flow::Steps::ProviderIncome::OutgoingsSummaryStep, type: :request do
  let(:application) { build_stubbed(:legal_aid_application, :with_applicant) }

  describe "#path" do
    subject { described_class.path.call(application) }

    it { is_expected.to eql providers_legal_aid_application_outgoings_summary_index_path(application) }
  end

  describe "#forward" do
    subject(:forward_step) { described_class.forward.call(application) }

    context "when applicant has a partner with no contrary interest" do
      let(:application) { build_stubbed(:legal_aid_application, :with_employed_applicant_and_employed_partner) }

      it { is_expected.to eq :partner_about_financial_means }
    end

    context "when there are housing payments for applicant" do
      let(:applicant) { create(:applicant, has_partner: false) }

      before do
        allow(application).to receive(:housing_payments_for?).with("Applicant").and_return(true)
      end

      it { is_expected.to eq :housing_benefits }
    end

    context "when none of those are true" do
      it { is_expected.to eq :has_dependants }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(application) }

    context "when there are housing payments for applicant" do
      let(:applicant) { create(:applicant, has_partner: false) }

      before do
        allow(application).to receive(:housing_payments_for?).with("Applicant").and_return(true)
        allow(application).to receive(:housing_payments_for?).with("Partner").and_return(false)
      end

      it { is_expected.to eq :housing_benefits }
    end

    context "when there are housing payments for partner" do
      let(:applicant) { create(:applicant, has_partner: false) }

      before do
        allow(application).to receive(:housing_payments_for?).with("Applicant").and_return(false)
        allow(application).to receive(:housing_payments_for?).with("Partner").and_return(true)
      end

      it { is_expected.to eq :housing_benefits }
    end

    context "when there are no housing payments for applicant or partner" do
      let(:applicant) { create(:applicant, has_partner: false) }

      before do
        allow(application).to receive(:housing_payments_for?).with("Applicant").and_return(false)
        allow(application).to receive(:housing_payments_for?).with("Partner").and_return(false)
      end

      it { is_expected.to eq :check_income_answers }
    end
  end
end
