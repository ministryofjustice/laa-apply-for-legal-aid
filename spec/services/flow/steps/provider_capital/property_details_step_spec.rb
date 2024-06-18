require "rails_helper"

RSpec.describe Flow::Steps::ProviderCapital::PropertyDetailsStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_means_property_details_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward }

    it { is_expected.to eq :vehicles }
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to eq :restrictions }
  end
end
