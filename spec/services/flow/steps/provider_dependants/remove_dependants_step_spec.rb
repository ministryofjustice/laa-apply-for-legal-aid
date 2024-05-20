require "rails_helper"

RSpec.describe Flow::Steps::ProviderDependants::RemoveDependantsStep, type: :request do
  let(:application) { create(:legal_aid_application, dependants: [dependant]) }
  let(:dependant) { create(:dependant) }

  describe "#path" do
    subject { described_class.path.call(application, dependant) }

    it { is_expected.to eq providers_legal_aid_application_means_remove_dependant_path(application, dependant) }
  end

  describe "#forward" do
    subject { described_class.forward.call(application) }

    context "when the provider choses yes to remove a dependant" do
      context "and dependants remain after the deletion" do
        it { is_expected.to eq :has_other_dependants }
      end

      context "and no dependants remain after deletion" do
        let(:application) { create(:legal_aid_application) }

        it { is_expected.to eq :has_dependants }
      end
    end
  end
end
