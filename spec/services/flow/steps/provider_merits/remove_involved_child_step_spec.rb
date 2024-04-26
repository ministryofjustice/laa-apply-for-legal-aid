require "rails_helper"

RSpec.describe Flow::Steps::ProviderMerits::RemoveInvolvedChildStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:child) { create(:involved_child, legal_aid_application:) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application, child) }

    it { is_expected.to eq providers_legal_aid_application_remove_involved_child_path(legal_aid_application, child) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    context "when at least one involved child remains on the application" do
      before { create(:involved_child, legal_aid_application:) }

      it { is_expected.to eq :has_other_involved_children }
    end

    context "when no involved_children remain on the application" do
      it { is_expected.to eq :involved_children }
    end
  end
end
