require "rails_helper"

RSpec.describe Flow::Steps::Addresses::DifferentAddressesStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application, applicant:) }
  let(:applicant) { create(:applicant, same_correspondence_and_home_address:) }
  let(:same_correspondence_and_home_address) { true }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_home_address_different_address_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    context "when the applicant has same correspondence and home address" do
      let(:same_correspondence_and_home_address) { true }

      context "and the linked_applications feature flag is enabled" do
        before do
          allow(Setting).to receive(:linked_applications?).and_return(true)
        end

        it { is_expected.to eq :link_application_make_links }
      end

      context "and the linked_applications feature flag is disabled" do
        context "and there are no proceedings on the application" do
          it { is_expected.to eq :proceedings_types }
        end

        context "and there are proceedings on the application" do
          let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, applicant:) }

          it { is_expected.to eq :has_other_proceedings }
        end
      end
    end

    context "when the applicant has different correspondence and home address" do
      let(:same_correspondence_and_home_address) { false }

      it { is_expected.to eq :different_address_reasons }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to eq :check_provider_answers }
  end

  describe "#carry_on_sub_flow" do
    subject { described_class.carry_on_sub_flow.call(legal_aid_application) }

    context "when the applicant has same correspondence and home address" do
      it { is_expected.to be false }
    end

    context "when the applicant has different correspondence and home address" do
      let(:same_correspondence_and_home_address) { false }

      it { is_expected.to be true }
    end
  end
end
