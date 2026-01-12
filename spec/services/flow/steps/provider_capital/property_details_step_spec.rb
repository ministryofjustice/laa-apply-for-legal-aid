require "rails_helper"

RSpec.describe Flow::Steps::ProviderCapital::PropertyDetailsStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application, property_value:, outstanding_mortgage_amount:) }
  let(:property_value) { 100_000 }
  let(:outstanding_mortgage_amount) { 100_000 }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_means_property_details_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    it { is_expected.to eq :vehicles }

    context "when outstanding mortgage amount is greater than property value" do
      let(:property_value) { 100_000 }
      let(:outstanding_mortgage_amount) { 101_000 }

      it { is_expected.to eq :property_details_interrupts }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to eq :restrictions }
  end
end
