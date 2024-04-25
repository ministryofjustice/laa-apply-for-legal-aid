require "rails_helper"

RSpec.describe Flow::Steps::LinkedApplications::ConfirmLinkStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application, link_case:) }
  let(:link_case) { true }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_link_application_confirm_link_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    context "when the provider confirms they wish to link the application" do
      it { is_expected.to be :link_application_copies }
    end

    context "when the provider confirms they do not want to link to an application" do
      let(:link_case) { false }

      it { is_expected.to be :proceedings_types }
    end

    context "when the provider confirms they want to link to a different application" do
      let(:link_case) { nil }

      it { is_expected.to be :link_application_make_links }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to be :check_provider_answers }
  end
end
