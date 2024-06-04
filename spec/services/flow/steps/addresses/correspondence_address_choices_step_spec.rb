require "rails_helper"

RSpec.describe Flow::Steps::Addresses::CorrespondenceAddressChoicesStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application) }
  let(:applicant) { build_stubbed(:applicant, legal_aid_application:) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_correspondence_address_choice_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    before { allow(applicant).to receive(:correspondence_address_choice).and_return(correspondence_address_choice) }

    context "when the provider has chosen home" do
      let(:correspondence_address_choice) { "home" }

      it { is_expected.to eq :home_address_lookups }
    end

    context "when the provider has chosen residence" do
      let(:correspondence_address_choice) { "residence" }

      it { is_expected.to eq :correspondence_address_lookups }
    end

    context "when the provider has chosen office" do
      let(:correspondence_address_choice) { "office" }

      it { is_expected.to eq :correspondence_address_manuals }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to eq :check_provider_answers }
  end

  describe "#carry_on_sub_flow" do
    subject { described_class.carry_on_sub_flow }

    it { is_expected.to be true }
  end
end
