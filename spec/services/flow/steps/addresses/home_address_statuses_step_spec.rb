require "rails_helper"

RSpec.describe Flow::Steps::Addresses::HomeAddressStatusesStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application, applicant:) }
  let(:applicant) { create(:applicant, no_fixed_residence:) }
  let(:no_fixed_residence) { true }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_home_address_status_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    context "when the applicant has no fixed residence" do
      let(:no_fixed_residence) { true }

      it { is_expected.to eq :link_application_make_links }
    end

    context "when the applicant has a fixed address" do
      let(:no_fixed_residence) { false }

      it { is_expected.to eq :home_address_lookups }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to eq :check_provider_answers }
  end

  describe "#carry_on_sub_flow" do
    subject { described_class.carry_on_sub_flow.call(legal_aid_application) }

    context "when the applicant has a fixed residence?" do
      let(:no_fixed_residence) { false }

      it { is_expected.to be true }
    end

    context "when the applicant has a fixed residence" do
      it { is_expected.to be false }
    end
  end
end
