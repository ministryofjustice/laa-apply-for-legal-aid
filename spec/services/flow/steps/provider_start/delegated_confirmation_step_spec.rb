require "rails_helper"

RSpec.describe Flow::Steps::ProviderStart::DelegatedConfirmationStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_delegated_confirmation_index_path(legal_aid_application) }
  end
end
