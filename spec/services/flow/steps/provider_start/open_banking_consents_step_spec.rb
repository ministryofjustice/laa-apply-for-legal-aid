require "rails_helper"

RSpec.describe Flow::Steps::ProviderStart::OpenBankingConsentsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application, provider_received_citizen_consent:) }
  let(:provider_received_citizen_consent) { true }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_open_banking_consents_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    context "when the provider has received the citizen's consent" do
      it { is_expected.to eq :open_banking_guidances }
    end

    context "when the provider has not received the citizen's consent" do
      let(:provider_received_citizen_consent) { false }

      it { is_expected.to eq :bank_statements }
    end
  end
end
