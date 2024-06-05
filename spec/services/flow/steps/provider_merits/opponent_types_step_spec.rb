require "rails_helper"

RSpec.describe Flow::Steps::ProviderMerits::OpponentTypesStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_opponent_type_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application, is_individual) }

    context "when is_individual is true" do
      let(:is_individual) { true }

      it { is_expected.to eq :opponent_individuals }
    end

    context "when is_individual is false" do
      let(:is_individual) { false }

      it { is_expected.to eq :opponent_existing_organisations }
    end
  end
end
