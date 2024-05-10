require "rails_helper"

RSpec.describe Flow::Steps::LinkedApplications::FindLinkStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_link_application_find_link_application_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward }

    it { is_expected.to eq :link_application_confirm_links }
  end
end
