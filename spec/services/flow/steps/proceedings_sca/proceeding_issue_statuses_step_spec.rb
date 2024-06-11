require "rails_helper"

RSpec.describe Flow::Steps::ProceedingsSCA::ProceedingIssueStatusesStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject(:path) { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_proceeding_issue_statuses_path(legal_aid_application) }
  end

  describe "#forward" do
    subject(:path) { described_class.forward }

    it { is_expected.to be :has_other_proceedings }
  end
end
