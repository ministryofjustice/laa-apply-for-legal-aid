require "rails_helper"

RSpec.describe Flow::Steps::Addresses::HomeAddressManualsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    context "when the linked_applications feature flag is enabled" do
      before do
        allow(Setting).to receive(:linked_applications?).and_return(true)
      end

      it { is_expected.to eq :link_application_make_links }
    end

    context "when linked_applications feature flag is disabled" do
      context "and there are no proceedings on the application" do
        it { is_expected.to eq :proceedings_types }
      end

      context "and there are proceedings on the application" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings) }

        it { is_expected.to eq :has_other_proceedings }
      end
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to eq :check_provider_answers }
  end
end
