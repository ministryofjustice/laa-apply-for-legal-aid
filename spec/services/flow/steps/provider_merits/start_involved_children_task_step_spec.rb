require "rails_helper"

RSpec.describe Flow::Steps::ProviderMerits::StartInvolvedChildrenTaskStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    context "when there are involved children" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_involved_children) }

      it { is_expected.to eq providers_legal_aid_application_has_other_involved_children_path(legal_aid_application) }
    end

    context "when there are no involved children" do
      it { is_expected.to eq new_providers_legal_aid_application_involved_child_path(legal_aid_application) }
    end
  end
end
