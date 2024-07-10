require "rails_helper"

RSpec.describe Flow::Steps::ProviderStart::ApplicantEmployedStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_applicant_employed_index_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    context "when the application is not eligible for the employment journey" do
      before { allow(legal_aid_application).to receive(:employment_journey_ineligible?).and_return(true) }

      it { is_expected.to eq :use_ccms_employment }
    end

    context "when the application uses delegated functions" do
      before { allow(legal_aid_application).to receive(:used_delegated_functions?).and_return(true) }

      it { is_expected.to eq :substantive_applications }
    end

    context "when the application does not use delegated functions" do
      before { allow(legal_aid_application).to receive(:used_delegated_functions?).and_return(false) }

      it { is_expected.to eq :open_banking_consents }
    end
  end
end
