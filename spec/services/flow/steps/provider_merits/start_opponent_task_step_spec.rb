require "rails_helper"

RSpec.describe Flow::Steps::ProviderMerits::StartOpponentTaskStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    context "when applicant has opponents" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_opponent) }

      it { is_expected.to eq providers_legal_aid_application_has_other_opponent_path(legal_aid_application) }
    end

    context "when applicant doesn't have opponents" do
      it { is_expected.to eq providers_legal_aid_application_opponent_type_path(legal_aid_application) }
    end
  end
end
