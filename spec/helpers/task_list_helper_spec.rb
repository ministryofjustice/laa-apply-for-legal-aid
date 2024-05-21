require "rails_helper"

RSpec.describe TaskListHelper do
  describe "#task_list_includes?" do
    subject(:task_list_includes?) { helper.task_list_includes?(legal_aid_application, task_name) }

    let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8) }
    let(:task_name) { :opponent_name }

    context "when the application has not been copied" do
      before do
        create(:legal_framework_merits_task_list, :da001, legal_aid_application:)
      end

      context "when task name is included in list of required tasks from LFA" do
        let(:task_name) { :opponent_name }

        it { is_expected.to be_truthy }
      end

      context "when task name is NOT included in list of required tasks from LFA" do
        let(:task_name) { :why_matter_opposed }

        it { is_expected.to be_falsey }
      end
    end

    context "when the application has been copied" do
      before do
        create(:legal_framework_merits_task_list, :da001, legal_aid_application: source_application)
        CopyCase::ClonerService.call(legal_aid_application, source_application)
      end

      let(:source_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8) }
      let(:legal_aid_application) { create(:legal_aid_application, copy_case: true, copy_case_id: source_application.id) }

      context "when task name is included in list of required tasks from LFA" do
        let(:task_name) { :opponent_name }

        it { is_expected.to be_truthy }
      end

      context "when task name is NOT included in list of required tasks from LFA" do
        let(:task_name) { :why_matter_opposed }

        it { is_expected.to be_falsey }
      end
    end
  end
end
