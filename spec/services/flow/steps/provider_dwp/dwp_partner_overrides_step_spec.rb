require "rails_helper"

RSpec.describe Flow::Steps::ProviderDWP::DWPPartnerOverridesStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_dwp_partner_override_path(legal_aid_application) }
  end

  describe "#forward" do
    subject(:forward_step) { described_class.forward }

    it { is_expected.to eq :check_client_details }
  end
end
