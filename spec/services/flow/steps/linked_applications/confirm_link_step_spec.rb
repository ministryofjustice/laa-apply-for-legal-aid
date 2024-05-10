require "rails_helper"

RSpec.describe Flow::Steps::LinkedApplications::ConfirmLinkStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:lead_application) { create(:legal_aid_application) }
  let(:link_case) { true }
  let(:link_type_code) { "FC_LEAD" }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_link_application_confirm_link_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    before do
      LinkedApplication.create!(lead_application_id: lead_application.id,
                                associated_application_id: legal_aid_application.id,
                                link_type_code:,
                                confirm_link:)
    end

    context "when the provider confirms they wish to link the application" do
      let(:confirm_link) { true }

      context "when the link type is family" do
        it { is_expected.to be :link_application_copies }
      end

      context "when the link_type is legal" do
        let(:link_type_code) { "LEGAL" }

        it { is_expected.to be :proceedings_types }
      end
    end

    context "when the provider confirms they do not want to link to an application" do
      let(:confirm_link) { false }

      it { is_expected.to be :proceedings_types }
    end

    context "when the provider confirms they want to link to a different application" do
      let(:confirm_link) { nil }

      it { is_expected.to be :link_application_make_links }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to be :check_provider_answers }
  end

  describe "#carry_on_sub_flow" do
    subject { described_class.carry_on_sub_flow.call(legal_aid_application) }

    context "when the lead_linked_application exists" do
      before { LinkedApplication.create!(lead_application_id: lead_application.id, associated_application_id: legal_aid_application.id, link_type_code:) }

      context "when link_type_code is FC_LEAD" do
        it { is_expected.to be true }
      end

      context "when link_type_code is LEGAL" do
        let(:link_type_code) { "LEGAL" }

        it { is_expected.to be false }
      end
    end

    context "when lead_linked_application is missing" do
      it { is_expected.to be false }
    end
  end
end
