require "rails_helper"

RSpec.describe Flow::Steps::ProviderStart::ProceedingsTypesStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_proceedings_types_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application, proceeding) }

    context "when the chosen proceeding does not have an sca_type" do
      let(:proceeding) { build_stubbed(:proceeding, :da004) }

      it { is_expected.to eq :has_other_proceedings }
    end

    context "when the chosen proceeding is an sca core proceeding" do
      let(:proceeding) { build_stubbed(:proceeding, :pb003) }

      it { is_expected.to eq :proceedings_sca_proceeding_issue_statuses }
    end

    context "when the chosen proceeding is an sca related proceeding" do
      let(:proceeding) { build_stubbed(:proceeding, :pb007) }

      it { is_expected.to eq :proceedings_sca_heard_togethers }
    end
  end
end
