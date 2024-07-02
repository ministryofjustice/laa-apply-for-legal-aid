require "rails_helper"

RSpec.describe Flow::Steps::ProviderStart::SubstantiveApplicationsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application, substantive_application:) }
  let(:substantive_application) { true }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_substantive_application_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    context "when the application is not a substantive application" do
      let(:substantive_application) { false }

      it { is_expected.to eq :delegated_confirmation }
    end

    context "when the application is a substantive application" do
      context "when the applicant receives benefits" do
        before { allow(legal_aid_application).to receive(:applicant_receives_benefit?).and_return(true) }

        it { is_expected.to eq :capital_introductions }
      end

      context "when the applicant does not receive benefits" do
        before { allow(legal_aid_application).to receive(:applicant_receives_benefit?).and_return(false) }

        it { is_expected.to eq :open_banking_consents }
      end
    end
  end
end
