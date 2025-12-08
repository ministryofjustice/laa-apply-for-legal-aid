require "rails_helper"

RSpec.describe Flow::Steps::Addresses::CorrespondenceAddressCareOfsStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application, applicant:) }
  let(:applicant) { build_stubbed(:applicant) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_correspondence_address_care_of_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward }

    it { is_expected.to eq :home_address_statuses }
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to eq :check_provider_answers }
  end

  describe "#carry_on_sub_flow" do
    subject { described_class.carry_on_sub_flow.call(legal_aid_application) }

    context "when applicant has NOT answered fixed residence question and address choice is residence" do
      let(:applicant) { build_stubbed(:applicant, no_fixed_residence: nil, correspondence_address_choice: "residence") }

      it { is_expected.to be true }
    end

    context "when applicant has NOT answered fixed residence question and address choice is office" do
      let(:applicant) { build_stubbed(:applicant, no_fixed_residence: nil, correspondence_address_choice: "office") }

      it { is_expected.to be true }
    end

    context "when applicant has NOT answered fixed residence question and corresspondence address choice is home" do
      let(:applicant) { build_stubbed(:applicant, no_fixed_residence: nil, correspondence_address_choice: "home") }

      it { is_expected.to be false }
    end

    context "when applicant has answered fixed residence question in the negative and corresspondence address choice is residence" do
      let(:applicant) { build_stubbed(:applicant, no_fixed_residence: false, correspondence_address_choice: "residence") }

      it { is_expected.to be false }
    end

    context "when applicant has answered fixed residence question in the affirmativeand corresspondence address choice is residence" do
      let(:applicant) { build_stubbed(:applicant, no_fixed_residence: true, correspondence_address_choice: "residence") }

      it { is_expected.to be false }
    end
  end
end
