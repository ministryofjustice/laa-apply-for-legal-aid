require "rails_helper"

RSpec.describe Flow::Steps::Addresses::CorrespondenceAddressManualsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:address) { create(:address, applicant: legal_aid_application.applicant, care_of:) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_correspondence_address_manual_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward }

    it { is_expected.to eq :correspondence_address_care_ofs }
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to eq :correspondence_address_care_ofs }
  end

  describe "#carry_on_sub_flow" do
    subject { described_class.carry_on_sub_flow.call(legal_aid_application) }

    before { address }

    context "when care of has already been answered" do
      let(:care_of) { "no" }

      it { is_expected.to be false }
    end

    context "when care of has not been answered" do
      let(:care_of) { nil }

      it { is_expected.to be true }
    end
  end
end
