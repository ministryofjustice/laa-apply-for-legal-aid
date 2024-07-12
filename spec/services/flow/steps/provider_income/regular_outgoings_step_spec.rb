require "rails_helper"

RSpec.describe Flow::Steps::ProviderIncome::RegularOutgoingsStep, type: :request do
  let(:application) { build_stubbed(:legal_aid_application, :with_applicant) }
  let(:applicant) { application.applicant }
  let(:outgoing_types?) { nil }

  before do
    allow(application).to receive_messages(outgoing_types?: outgoing_types?)
  end

  describe "#path" do
    subject { described_class.path.call(application) }

    it { is_expected.to eql providers_legal_aid_application_means_regular_outgoings_path(application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(application) }

    context "when applicant outgoing types is true" do
      before { allow(application).to receive(:applicant_outgoing_types?).and_return(true) }

      it { is_expected.to eq :cash_outgoings }
    end

    context "when applicant has a partner with no contrary interest" do
      let(:application) { build_stubbed(:legal_aid_application, :with_employed_applicant_and_employed_partner) }

      it { is_expected.to eq :partner_about_financial_means }
    end

    context "when none of those are true" do
      it { is_expected.to eq :has_dependants }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(application) }

    context "when applicant has outgoing types" do
      before { allow(application).to receive(:applicant_outgoing_types?).and_return(true) }

      it { is_expected.to eq :cash_outgoings }
    end

    context "when applicant does not have outgoing types" do
      before { allow(application).to receive(:applicant_outgoing_types?).and_return(false) }

      it { is_expected.to eq :check_income_answers }
    end
  end
end
