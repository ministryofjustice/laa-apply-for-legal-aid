require "rails_helper"

RSpec.describe Flow::Steps::ProviderDependants::DependantsStep, type: :request do
  let(:application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(application) }

    it { is_expected.to eq new_providers_legal_aid_application_means_dependant_path(application) }
  end

  describe "#forward" do
    subject { described_class.forward }

    it { is_expected.to eq :has_other_dependants }
  end
end
