require "rails_helper"

RSpec.describe Flow::Steps::ProviderIncome::IdentifyTypesOfOutgoingsStep, type: :request do
  let(:application) { build_stubbed(:legal_aid_application, :with_applicant) }
  let(:applicant) { application.applicant }
  let(:outgoing_types?) { nil }
  let(:income_types?) { nil }
  let(:uploading_bank_statements?) { nil }

  before do
    allow(application).to receive_messages(outgoing_types?: outgoing_types?,
                                           income_types?: income_types?,
                                           uploading_bank_statements?: uploading_bank_statements?)
  end

  describe "#path" do
    subject { described_class.path.call(application) }

    it { is_expected.to eql providers_legal_aid_application_means_identify_types_of_outgoing_path(application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(application) }

    context "when outgoing types is true" do
      let(:outgoing_types?) { true }

      it { is_expected.to eq :cash_outgoings }
    end

    context "when income types is true and is not uploading bank statements" do
      let(:income_types?) { true }
      let(:uploading_bank_statements?) { false }

      it { is_expected.to eq :income_summary }
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
      before { allow(application).to receive(:outgoing_types?).and_return(true) }

      it { is_expected.to eq :cash_outgoings }
    end

    context "when application has no outgoing types" do
      before { allow(application).to receive(:outgoing_types?).and_return(false) }

      it { is_expected.to eq :check_income_answers }
    end
  end
end
