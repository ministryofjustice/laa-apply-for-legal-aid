require "rails_helper"

RSpec.describe Flow::Steps::ProviderIncome::CashOutgoingsStep, type: :request do
  let(:application) { create(:application, applicant:) }
  let(:applicant) { create(:applicant, has_partner: true, partner_has_contrary_interest: false) }

  describe "#path" do
    subject { described_class.path.call(application) }

    it { is_expected.to eql providers_legal_aid_application_means_cash_outgoing_path(application) }
  end

  describe "#forward" do
    subject(:forward_step) { described_class.forward.call(application) }

    context "when not uploading bank statements" do
      before { allow(application).to receive(:uploading_bank_statements?).and_return(false) }

      context "when the application has income types" do
        before { allow(application).to receive(:income_types?).and_return(true) }

        it { is_expected.to eq :income_summary }
      end

      context "when the application has outgoing types" do
        before { allow(application).to receive(:outgoing_types?).and_return(true) }

        it { is_expected.to eq :outgoings_summary }
      end
    end

    context "when applicant has a partner with no contrary interest" do
      it { is_expected.to eq :partner_about_financial_means }
    end

    context "when there are housing payments for applicant" do
      let(:applicant) { create(:applicant, has_partner: false) }

      before do
        allow(application).to receive(:housing_payments_for?).with("Applicant").and_return(true)
        allow(application).to receive(:uploading_bank_statements?).and_return(true)
      end

      it { is_expected.to eq :housing_benefits }
    end

    context "when there are no housing payments for applicant" do
      let(:applicant) { create(:applicant, has_partner: false) }

      before do
        allow(application).to receive(:housing_payments_for?).with("Applicant").and_return(false)
        allow(application).to receive(:uploading_bank_statements?).and_return(true)
      end

      it { is_expected.to eq :has_dependants }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(application) }

    context "when uploading bank statements" do
      before { allow(application).to receive(:uploading_bank_statements?).and_return(true) }

      context "when there are housing payments for applicant" do
        let(:applicant) { create(:applicant, has_partner: false) }

        before do
          allow(application).to receive(:housing_payments_for?).with("Applicant").and_return(true)
        end

        it { is_expected.to eq :housing_benefits }
      end

      context "when there are no housing payments for applicant" do
        let(:applicant) { create(:applicant, has_partner: false) }

        before do
          allow(application).to receive(:housing_payments_for?).with("Applicant").and_return(false)
        end

        it { is_expected.to eq :check_income_answers }
      end
    end

    context "when not uploading bank statements" do
      before { allow(application).to receive(:uploading_bank_statements?).and_return(false) }

      it { is_expected.to eq :outgoings_summary }
    end
  end
end
