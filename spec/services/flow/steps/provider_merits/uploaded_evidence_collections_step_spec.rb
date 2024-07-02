require "rails_helper"

RSpec.describe Flow::Steps::ProviderMerits::UploadedEvidenceCollectionsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_uploaded_evidence_collection_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward }

    it { is_expected.to eq :check_merits_answers }
  end
end
