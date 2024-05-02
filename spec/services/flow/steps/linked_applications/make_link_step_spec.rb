require "rails_helper"

RSpec.describe Flow::Steps::LinkedApplications::MakeLinkStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_link_application_make_link_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    context "when the application has a linked_application" do
      before { create(:linked_application, associated_application: legal_aid_application) }

      it { is_expected.to eq :link_application_find_link_applications }
    end

    context "when the application does not have a linked_application" do
      context "when the application has proceedings" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings) }

        it { is_expected.to eq :has_other_proceedings }
      end

      context "when the application has no proceedings" do
        it { is_expected.to eq :proceedings_types }
      end
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to eq :check_provider_answers }
  end

  describe "#carry_on_sub_flow" do
    subject { described_class.carry_on_sub_flow.call(legal_aid_application) }

    context "when the applicant has a linked_application" do
      before { create(:linked_application, associated_application: legal_aid_application) }

      it { is_expected.to be true }
    end

    context "when the applicant does not have a linked_application" do
      it { is_expected.to be false }
    end
  end
end
