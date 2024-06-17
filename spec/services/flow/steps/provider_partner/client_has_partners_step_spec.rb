require "rails_helper"

RSpec.describe Flow::Steps::ProviderPartner::ClientHasPartnersStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_client_has_partner_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application, options) }

    context "when provider has partner" do
      let(:options) { { has_partner: true } }

      it { is_expected.to be :contrary_interests }
    end

    context "when provider doesn't have partner" do
      let(:options) { { has_partner: false } }

      it { is_expected.to be :check_provider_answers }
    end
  end
end
