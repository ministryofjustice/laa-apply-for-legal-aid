require "rails_helper"

RSpec.describe Flow::Steps::ProviderStart::OpenBankingGuidancesStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_open_banking_guidance_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application, client_can_use_truelayer) }

    context "when the provider has received the citizen's consent" do
      let(:client_can_use_truelayer) { true }

      it { is_expected.to eq :email_addresses }
    end

    context "when the provider has not received the citizen's consent" do
      let(:client_can_use_truelayer) { false }

      it { is_expected.to eq :bank_statements }
    end
  end
end
