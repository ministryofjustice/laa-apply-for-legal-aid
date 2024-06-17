require "rails_helper"

RSpec.describe Flow::Steps::ProviderIncome::IncomeSummaryStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application, applicant:) }
  let(:applicant) { create(:applicant) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_income_summary_index_path(legal_aid_application) }
  end

  describe "#forward" do
    subject(:forward_step) { described_class.forward.call(legal_aid_application) }

    context "when applicant has outgoings" do
      before { allow(legal_aid_application).to receive(:outgoing_types?).and_return(true) }

      it { is_expected.to eq :outgoings_summary }
    end

    context "when applicant has a partner with no contrary interest" do
      let(:applicant) { create(:applicant, :with_partner) }

      it { is_expected.to eq :partner_about_financial_means }
    end

    context "when applicant does not have a partner" do
      it { is_expected.to eq :has_dependants }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to eq :check_income_answers }
  end
end
