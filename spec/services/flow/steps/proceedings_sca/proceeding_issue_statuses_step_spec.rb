require "rails_helper"

RSpec.describe Flow::Steps::ProceedingsSCA::ProceedingIssueStatusesStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application) }

  describe "#path" do
    subject(:path) { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_proceeding_issue_statuses_path(legal_aid_application) }
  end

  describe "#forward" do
    subject(:path) { described_class.forward.call(legal_aid_application, proceeding) }

    context "when the current proceeding is a secure accommodation order, PB006" do
      let(:proceeding) { build_stubbed(:proceeding, ccms_code: "PB006") }

      it { is_expected.to be :proceedings_sca_child_subjects }
    end

    context "when the current proceeding is a supervision order, PB059" do
      let(:proceeding) { build_stubbed(:proceeding, :pb059) }

      it { is_expected.to be :proceedings_sca_supervision_orders }
    end

    context "when neither of those proceedings" do
      let(:proceeding) { build_stubbed(:proceeding, :pb003) }

      it { is_expected.to be :has_other_proceedings }
    end
  end
end
