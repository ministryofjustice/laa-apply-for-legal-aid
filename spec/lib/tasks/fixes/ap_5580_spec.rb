require "rails_helper"

RSpec.describe "fixes:ap_5580", type: :task do
  subject(:task) { Rake::Task["fixes:ap_5580"] }

  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task["fixes:ap_5580"].reenable
    allow(Rails.logger).to receive(:info)
    allow($stdout).to receive(:write) if ENV["CI"] # comment this out if using binding.pry in this file
    create(:legal_framework_merits_task_list, serialized_data:, legal_aid_application:)
  end

  describe "when there are no applications with the question" do
    let(:legal_aid_application) do
      travel_to Date.parse("2025-02-21") do
        create(:legal_aid_application, :with_applicant, :at_provider_entering_merits, provider_step: "merits_task_lists")
      end
    end
    let(:serialized_data) { single_proceeding_without_question[:task_list] }

    it { expect { task.execute }.to output(single_proceeding_without_question[:output]).to_stdout }
  end

  describe "when the application is on the check who client is page" do
    let(:legal_aid_application) do
      travel_to Date.parse("2025-02-21") do
        create(:legal_aid_application, :with_applicant, :at_provider_entering_merits, provider_step: "check_who_client_is")
      end
    end
    let(:serialized_data) { single_proceeding_with_question[:task_list] }

    before { create(:proceeding, :pb007, legal_aid_application:, relationship_to_child: "biological") }

    it "updates the provider_step to point to the new page" do
      expect { task.execute(dry_run: false) }.to change { legal_aid_application.reload.provider_step }
                                                   .from("check_who_client_is")
                                                   .to("application_merits_task_client_check_parental_answers")
    end
  end

  context "when there is a submitted application" do
    let(:legal_aid_application) do
      travel_to Date.parse("2025-02-21") do
        create(:legal_aid_application, :with_applicant, :at_assessment_submitted, provider_step: "submitted_applications")
      end
    end

    let(:proceedings) { legal_aid_application.proceedings }

    describe "and the client_relationship_to_proceeding was not asked" do
      let(:serialized_data) { single_proceeding_without_question[:task_list] }

      it { expect { task.execute }.to output(single_proceeding_without_question[:output]).to_stdout }
    end

    context "and the single client_relationship_to_proceeding question has been answered" do
      before { create(:proceeding, :pb007, legal_aid_application:, relationship_to_child: "biological") }

      let(:serialized_data) { single_proceeding_with_answered_question[:task_list] }

      it { expect { task.execute }.to output(single_proceeding_with_answered_question[:dry_run_output]).to_stdout }

      context "when the dry_run flag is not set, or true" do
        it "does not affect the task list or data" do
          task.execute
          expect(legal_aid_application.legal_framework_merits_task_list).to have_task_in_state(:PB057, :client_relationship_to_proceeding, :complete)
          expect(legal_aid_application.legal_framework_merits_task_list).not_to have_task_in_state(:application, :client_relationship_to_children, :not_started)
        end
      end

      context "when the dry_run flag is false" do
        it "outputs a message and updates the data" do
          expect { task.execute(dry_run: false) }.to output(single_proceeding_with_answered_question[:live_output]).to_stdout
          expect(legal_aid_application.legal_framework_merits_task_list).not_to have_task_in_state(:PB057, :client_relationship_to_proceeding, :complete)
          expect(legal_aid_application.legal_framework_merits_task_list).to have_task_in_state(:application, :client_relationship_to_children, :complete)
          expect(legal_aid_application.applicant.reload.relationship_to_children).to eq proceedings.map(&:relationship_to_child).uniq.first
        end
      end
    end

    context "and multiple client_relationship_to_proceeding questions have been answered with the same response" do
      let(:serialized_data) { double_proceeding_submitted_with_question[:task_list] }

      before do
        create(:proceeding, :pb003, legal_aid_application:, relationship_to_child: "biological")
        create(:proceeding, :pb007, legal_aid_application:, relationship_to_child: "biological")
      end

      context "when the dry_run flag is not set, or true" do
        it { expect { task.execute }.to output(double_proceeding_submitted_with_question[:dry_run_output]).to_stdout }

        it "does not affect the task list or data" do
          task.execute
          expect(legal_aid_application.legal_framework_merits_task_list).to have_task_in_state(:PB003, :client_relationship_to_proceeding, :complete)
          expect(legal_aid_application.legal_framework_merits_task_list).to have_task_in_state(:PB007, :client_relationship_to_proceeding, :complete)
          expect(legal_aid_application.legal_framework_merits_task_list).not_to have_task_in_state(:application, :client_relationship_to_children, :not_started)
        end
      end

      context "when the dry_run flag is false" do
        it "outputs a message and does not update the data" do
          expect { task.execute(dry_run: false) }.to output(double_proceeding_submitted_with_question[:live_output]).to_stdout
          expect(legal_aid_application.legal_framework_merits_task_list).not_to have_task_in_state(:PB003, :client_relationship_to_proceeding, :complete)
          expect(legal_aid_application.legal_framework_merits_task_list).not_to have_task_in_state(:PB007, :client_relationship_to_proceeding, :complete)
          expect(legal_aid_application.legal_framework_merits_task_list).to have_task_in_state(:application, :client_relationship_to_children, :complete)
          expect(legal_aid_application.applicant.reload.relationship_to_children).to eq proceedings.map(&:relationship_to_child).uniq.first
        end
      end
    end

    context "and multiple client_relationship_to_proceeding questions have been answered with different responses" do
      let(:serialized_data) { double_proceeding_with_mis_matched_answered_question[:task_list] }

      before do
        create(:proceeding, :pb003, legal_aid_application:, relationship_to_child: "biological")
        create(:proceeding, :pb007, legal_aid_application:, relationship_to_child: "court_order")
      end

      context "when the dry_run flag is not set, or true" do
        it { expect { task.execute }.to output(double_proceeding_submitted_with_mis_matched_answered_question[:dry_run_output]).to_stdout }

        it "does not affect the task list or data" do
          task.execute
          expect(legal_aid_application.legal_framework_merits_task_list).to have_task_in_state(:PB003, :client_relationship_to_proceeding, :complete)
          expect(legal_aid_application.legal_framework_merits_task_list).to have_task_in_state(:PB007, :client_relationship_to_proceeding, :complete)
          expect(legal_aid_application.legal_framework_merits_task_list).not_to have_task_in_state(:application, :client_relationship_to_children, :complete)
        end
      end

      context "when the dry_run flag is false" do
        it "outputs a message and does not update the data" do
          expect { task.execute(dry_run: false) }.to output(double_proceeding_submitted_with_mis_matched_answered_question[:live_output]).to_stdout
          expect(legal_aid_application.legal_framework_merits_task_list).to have_task_in_state(:PB003, :client_relationship_to_proceeding, :complete)
          expect(legal_aid_application.legal_framework_merits_task_list).to have_task_in_state(:PB007, :client_relationship_to_proceeding, :complete)
          expect(legal_aid_application.legal_framework_merits_task_list).not_to have_task_in_state(:application, :client_relationship_to_children, :complete)
          expect(legal_aid_application.applicant.reload.relationship_to_children).to be_nil
        end
      end
    end
  end

  describe "when there is an in-progress application" do
    let(:legal_aid_application) do
      travel_to Date.parse("2025-02-21") do
        create(:legal_aid_application, :with_applicant, :at_provider_entering_merits, provider_step: "merits_task_lists")
      end
    end
    let(:proceedings) { legal_aid_application.proceedings }

    describe "and the client_relationship_to_proceeding was not asked" do
      let(:serialized_data) { single_proceeding_without_question[:task_list] }

      context "when the dry_run flag is not set, or true" do
        it { expect { task.execute }.to output(single_proceeding_without_question[:output]).to_stdout }
      end
    end

    describe "and the single client_relationship_to_proceeding question has been answered" do
      before { create(:proceeding, :pb007, legal_aid_application:, relationship_to_child: "biological") }

      let(:serialized_data) { single_proceeding_with_question[:task_list] }

      context "when the dry_run flag is not set, or true" do
        it { expect { task.execute }.to output(single_proceeding_with_question[:dry_run_output]).to_stdout }

        it "does not affect the task list or data" do
          task.execute
          expect(legal_aid_application.legal_framework_merits_task_list).to have_task_in_state(:PB057, :client_relationship_to_proceeding, :not_started)
          expect(legal_aid_application.legal_framework_merits_task_list).not_to have_task_in_state(:application, :client_relationship_to_children, :not_started)
        end
      end

      context "when the dry_run flag is false" do
        it "outputs a message and updates the data" do
          expect { task.execute(dry_run: false) }.to output(single_proceeding_with_question[:live_output]).to_stdout
          expect(legal_aid_application.legal_framework_merits_task_list).not_to have_task_in_state(:PB057, :client_relationship_to_proceeding, :not_started)
          expect(legal_aid_application.legal_framework_merits_task_list).to have_task_in_state(:application, :client_relationship_to_children, :not_started)
          expect(legal_aid_application.applicant.reload.relationship_to_children).to eq proceedings.map(&:relationship_to_child).uniq.first
        end
      end
    end

    describe "and multiple client_relationship_to_proceeding questions have been answered with the same response" do
      let(:serialized_data) { double_proceeding_with_question[:task_list] }

      before do
        create(:proceeding, :pb003, legal_aid_application:, relationship_to_child: "biological")
        create(:proceeding, :pb007, legal_aid_application:, relationship_to_child: "biological")
      end

      context "when the dry_run flag is not set, or true" do
        it { expect { task.execute }.to output(double_proceeding_with_question[:dry_run_output]).to_stdout }

        it "does not affect the task list or data" do
          task.execute
          expect(legal_aid_application.legal_framework_merits_task_list).to have_task_in_state(:PB003, :client_relationship_to_proceeding, :not_started)
          expect(legal_aid_application.legal_framework_merits_task_list).to have_task_in_state(:PB007, :client_relationship_to_proceeding, :not_started)
          expect(legal_aid_application.legal_framework_merits_task_list).not_to have_task_in_state(:application, :client_relationship_to_children, :not_started)
        end
      end

      context "when the dry_run flag is false" do
        it "outputs a message and updates the data" do
          expect { task.execute(dry_run: false) }.to output(double_proceeding_with_question[:live_output]).to_stdout
          expect(legal_aid_application.legal_framework_merits_task_list).not_to have_task_in_state(:PB003, :client_relationship_to_proceeding, :not_started)
          expect(legal_aid_application.legal_framework_merits_task_list).not_to have_task_in_state(:PB007, :client_relationship_to_proceeding, :not_started)
          expect(legal_aid_application.legal_framework_merits_task_list).to have_task_in_state(:application, :client_relationship_to_children, :not_started)
          expect(legal_aid_application.applicant.reload.relationship_to_children).to eq proceedings.map(&:relationship_to_child).uniq.first
        end
      end
    end

    describe "and multiple client_relationship_to_proceeding questions have been answered with different responses" do
      let(:serialized_data) { double_proceeding_with_mis_matched_answered_question[:task_list] }

      before do
        create(:proceeding, :pb003, legal_aid_application:, relationship_to_child: "biological")
        create(:proceeding, :pb007, legal_aid_application:, relationship_to_child: "court_order")
      end

      context "when the dry_run flag is not set, or true" do
        it { expect { task.execute }.to output(double_proceeding_with_mis_matched_answered_question[:dry_run_output]).to_stdout }

        it "does not affect the task list or data" do
          task.execute
          expect(legal_aid_application.legal_framework_merits_task_list).to have_task_in_state(:PB003, :client_relationship_to_proceeding, :complete)
          expect(legal_aid_application.legal_framework_merits_task_list).to have_task_in_state(:PB007, :client_relationship_to_proceeding, :complete)
          expect(legal_aid_application.legal_framework_merits_task_list).not_to have_task_in_state(:application, :client_relationship_to_children, :not_started)
        end
      end

      context "when the dry_run flag is false" do
        it "outputs a message and does not update the data" do
          expect { task.execute(dry_run: false) }.to output(double_proceeding_with_mis_matched_answered_question[:live_output]).to_stdout
          expect(legal_aid_application.legal_framework_merits_task_list).to have_task_in_state(:PB003, :client_relationship_to_proceeding, :complete)
          expect(legal_aid_application.legal_framework_merits_task_list).to have_task_in_state(:PB007, :client_relationship_to_proceeding, :complete)
          expect(legal_aid_application.legal_framework_merits_task_list).not_to have_task_in_state(:application, :client_relationship_to_children, :not_started)
          expect(legal_aid_application.applicant.reload.relationship_to_children).to be_nil
        end
      end
    end
  end
end

def single_proceeding_without_question
  {
    task_list: "--- !ruby/object:LegalFramework::SerializableMeritsTaskList\nlfa_response:\n  :request_id: 6fdad3d4-c0bf-4332-996e-2c24bff0fd80\n  :success: true\n  :application:\n    :tasks:\n      :latest_incident_details: &1 []\n      :opponent_name: &2 []\n      :opponent_mental_capacity: &3 []\n      :domestic_abuse_summary: &4 []\n      :statement_of_case: &5 []\n  :proceedings:\n  - :ccms_code: DA004\n    :tasks:\n      :chances_of_success: &6 []\ntasks:\n  :application:\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :latest_incident_details\n    dependencies: *1\n    state: :complete\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :opponent_name\n    dependencies: *2\n    state: :complete\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :opponent_mental_capacity\n    dependencies: *3\n    state: :complete\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :domestic_abuse_summary\n    dependencies: *4\n    state: :complete\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :statement_of_case\n    dependencies: *5\n    state: :complete\n  :proceedings:\n    :DA004:\n      :name: Non-molestation order\n      :tasks:\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :chances_of_success\n        dependencies: *6\n        state: :complete\n",
    output: <<~STRING,
      {affected: 0,
       submitted: 0,
       answered: 0,
       fixable: 0,
       investigate: 0,
       migrated: 0,
       data: []}
    STRING
  }
end

def single_proceeding_with_question
  {
    task_list: "--- !ruby/object:LegalFramework::SerializableMeritsTaskList\nlfa_response:\n  :request_id: 7ebd1d6d-a3be-4151-a5db-c8ece94c72ff\n  :success: true\n  :application:\n    :tasks:\n      :opponent_name: &1 []\n      :children_application: &2 []\n  :proceedings:\n  - :ccms_code: PB057\n    :tasks:\n      :children_proceeding: &3 []\n      :client_relationship_to_proceeding: &4 []\ntasks:\n  :application:\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :opponent_name\n    dependencies: *1\n    state: :complete\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :children_application\n    dependencies: *2\n    state: :complete\n  :proceedings:\n    :PB057:\n      :name: Care order\n      :tasks:\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :children_proceeding\n        dependencies: *3\n        state: :complete\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :client_relationship_to_proceeding\n        dependencies: *4\n        state: :not_started\n",
    dry_run_output: <<~STRING,
      {affected: 1,
       submitted: 0,
       answered: 0,
       fixable: 1,
       investigate: 0,
       migrated: 0,
       data:
        [{id: "#{legal_aid_application.id}",
          ref: "#{legal_aid_application.application_ref}",
          proceedings: 1,
          proceeding_states: [:not_started],
          proceeding_answers: ["biological"]}]}
    STRING
    live_output: <<~STRING,
      {affected: 1,
       submitted: 0,
       answered: 0,
       fixable: 1,
       investigate: 0,
       migrated: 1,
       data:
        [{id: "#{legal_aid_application.id}",
          ref: "#{legal_aid_application.application_ref}",
          proceedings: 1,
          proceeding_states: [:not_started],
          proceeding_answers: ["biological"],
          fixed: true}]}
    STRING
  }
end

def single_proceeding_with_answered_question
  {
    task_list: "--- !ruby/object:LegalFramework::SerializableMeritsTaskList\nlfa_response:\n  :request_id: 7ebd1d6d-a3be-4151-a5db-c8ece94c72ff\n  :success: true\n  :application:\n    :tasks:\n      :opponent_name: &1 []\n      :children_application: &2 []\n  :proceedings:\n  - :ccms_code: PB057\n    :tasks:\n      :children_proceeding: &3 []\n      :client_relationship_to_proceeding: &4 []\ntasks:\n  :application:\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :opponent_name\n    dependencies: *1\n    state: :complete\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :children_application\n    dependencies: *2\n    state: :complete\n  :proceedings:\n    :PB057:\n      :name: Care order\n      :tasks:\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :children_proceeding\n        dependencies: *3\n        state: :complete\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :client_relationship_to_proceeding\n        dependencies: *4\n        state: :complete\n",
    dry_run_output: <<~STRING,
      {affected: 1,
       submitted: 1,
       answered: 1,
       fixable: 1,
       investigate: 0,
       migrated: 0,
       data:
        [{id: "#{legal_aid_application.id}",
          ref: "#{legal_aid_application.application_ref}",
          proceedings: 1,
          proceeding_states: [:complete],
          proceeding_answers: ["biological"]}]}
    STRING
    live_output: <<~STRING,
      {affected: 1,
       submitted: 1,
       answered: 1,
       fixable: 1,
       investigate: 0,
       migrated: 1,
       data:
        [{id: "#{legal_aid_application.id}",
          ref: "#{legal_aid_application.application_ref}",
          proceedings: 1,
          proceeding_states: [:complete],
          proceeding_answers: ["biological"],
          fixed: true}]}
    STRING
  }
end

def double_proceeding_with_question
  {
    task_list: "--- !ruby/object:LegalFramework::SerializableMeritsTaskList\nlfa_response:\n  :request_id: 42ef6c04-2bf7-49e7-beae-48cc63e5cd6e\n  :success: true\n  :application:\n    :tasks:\n      :opponent_name: &1 []\n      :children_application: &2 []\n  :proceedings:\n  - :ccms_code: PB003\n    :tasks:\n      :children_proceeding: &3\n      - children_application\n      :client_relationship_to_proceeding: &4 []\n  - :ccms_code: PB007\n    :tasks:\n      :children_proceeding: &5\n      - children_application\n      :client_relationship_to_proceeding: &6 []\ntasks:\n  :application:\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :opponent_name\n    dependencies: *1\n    state: :not_started\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :children_application\n    dependencies: *2\n    state: :not_started\n  :proceedings:\n    :PB003:\n      :name: Emergency protection order - extend\n      :tasks:\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :children_proceeding\n        dependencies: *3\n        state: :waiting_for_dependency\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :client_relationship_to_proceeding\n        dependencies: *4\n        state: :not_started\n    :PB007:\n      :name: Emergency protection order - discharge\n      :tasks:\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :children_proceeding\n        dependencies: *5\n        state: :waiting_for_dependency\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :client_relationship_to_proceeding\n        dependencies: *6\n        state: :not_started\n",
    dry_run_output: <<~STRING,
      {affected: 1,
       submitted: 0,
       answered: 0,
       fixable: 1,
       investigate: 0,
       migrated: 0,
       data:
        [{id: "#{legal_aid_application.id}",
          ref: "#{legal_aid_application.application_ref}",
          proceedings: 2,
          proceeding_states: [:not_started],
          proceeding_answers: ["biological"]}]}
    STRING
    live_output: <<~STRING,
      {affected: 1,
       submitted: 0,
       answered: 0,
       fixable: 1,
       investigate: 0,
       migrated: 1,
       data:
        [{id: "#{legal_aid_application.id}",
          ref: "#{legal_aid_application.application_ref}",
          proceedings: 2,
          proceeding_states: [:not_started],
          proceeding_answers: ["biological"],
          fixed: true}]}
    STRING
  }
end

def double_proceeding_submitted_with_question
  {
    task_list: "--- !ruby/object:LegalFramework::SerializableMeritsTaskList\nlfa_response:\n  :request_id: 42ef6c04-2bf7-49e7-beae-48cc63e5cd6e\n  :success: true\n  :application:\n    :tasks:\n      :opponent_name: &1 []\n      :children_application: &2 []\n  :proceedings:\n  - :ccms_code: PB003\n    :tasks:\n      :children_proceeding: &3\n      - children_application\n      :client_relationship_to_proceeding: &4 []\n  - :ccms_code: PB007\n    :tasks:\n      :children_proceeding: &5\n      - children_application\n      :client_relationship_to_proceeding: &6 []\ntasks:\n  :application:\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :opponent_name\n    dependencies: *1\n    state: :not_started\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :children_application\n    dependencies: *2\n    state: :not_started\n  :proceedings:\n    :PB003:\n      :name: Emergency protection order - extend\n      :tasks:\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :children_proceeding\n        dependencies: *3\n        state: :waiting_for_dependency\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :client_relationship_to_proceeding\n        dependencies: *4\n        state: :complete\n    :PB007:\n      :name: Emergency protection order - discharge\n      :tasks:\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :children_proceeding\n        dependencies: *5\n        state: :waiting_for_dependency\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :client_relationship_to_proceeding\n        dependencies: *6\n        state: :complete\n",
    dry_run_output: <<~STRING,
      {affected: 1,
       submitted: 1,
       answered: 1,
       fixable: 1,
       investigate: 0,
       migrated: 0,
       data:
        [{id: "#{legal_aid_application.id}",
          ref: "#{legal_aid_application.application_ref}",
          proceedings: 2,
          proceeding_states: [:complete],
          proceeding_answers: ["biological"]}]}
    STRING
    live_output: <<~STRING,
      {affected: 1,
       submitted: 1,
       answered: 1,
       fixable: 1,
       investigate: 0,
       migrated: 1,
       data:
        [{id: "#{legal_aid_application.id}",
          ref: "#{legal_aid_application.application_ref}",
          proceedings: 2,
          proceeding_states: [:complete],
          proceeding_answers: ["biological"],
          fixed: true}]}
    STRING
  }
end

def double_proceeding_with_answered_question
  {
    task_list: "--- !ruby/object:LegalFramework::SerializableMeritsTaskList\nlfa_response:\n  :request_id: 42ef6c04-2bf7-49e7-beae-48cc63e5cd6e\n  :success: true\n  :application:\n    :tasks:\n      :opponent_name: &1 []\n      :children_application: &2 []\n  :proceedings:\n  - :ccms_code: PB003\n    :tasks:\n      :children_proceeding: &3\n      - children_application\n      :client_relationship_to_proceeding: &4 []\n  - :ccms_code: PB007\n    :tasks:\n      :children_proceeding: &5\n      - children_application\n      :client_relationship_to_proceeding: &6 []\ntasks:\n  :application:\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :opponent_name\n    dependencies: *1\n    state: :not_started\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :children_application\n    dependencies: *2\n    state: :not_started\n  :proceedings:\n    :PB003:\n      :name: Emergency protection order - extend\n      :tasks:\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :children_proceeding\n        dependencies: *3\n        state: :waiting_for_dependency\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :client_relationship_to_proceeding\n        dependencies: *4\n        state: :complete\n    :PB007:\n      :name: Emergency protection order - discharge\n      :tasks:\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :children_proceeding\n        dependencies: *5\n        state: :waiting_for_dependency\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :client_relationship_to_proceeding\n        dependencies: *6\n        state: :complete\n",
    dry_run_output: <<~STRING,
      {affected: 1,
       submitted: 1,
       answered: 1,
       fixable: 1,
       investigate: 0,
       migrated: 0,
       data:
        [{id: "#{legal_aid_application.id}",
          ref: "#{legal_aid_application.application_ref}",
          proceedings: 2,
          proceeding_states: [:complete],
          proceeding_answers: ["biological"]}]}
    STRING
    live_output: <<~STRING,
      {affected: 1,
       submitted: 1,
       answered: 1,
       fixable: 1,
       investigate: 0,
       migrated: 0,
       data:
        [{id: "#{legal_aid_application.id}",
          ref: "#{legal_aid_application.application_ref}",
          proceedings: 2,
          proceeding_states: [:complete],
          proceeding_answers: ["biological"],
          fixed: false}]}
    STRING
  }
end

def double_proceeding_with_mis_matched_answered_question
  {
    task_list: "--- !ruby/object:LegalFramework::SerializableMeritsTaskList\nlfa_response:\n  :request_id: 42ef6c04-2bf7-49e7-beae-48cc63e5cd6e\n  :success: true\n  :application:\n    :tasks:\n      :opponent_name: &1 []\n      :children_application: &2 []\n  :proceedings:\n  - :ccms_code: PB003\n    :tasks:\n      :children_proceeding: &3\n      - children_application\n      :client_relationship_to_proceeding: &4 []\n  - :ccms_code: PB007\n    :tasks:\n      :children_proceeding: &5\n      - children_application\n      :client_relationship_to_proceeding: &6 []\ntasks:\n  :application:\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :opponent_name\n    dependencies: *1\n    state: :not_started\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :children_application\n    dependencies: *2\n    state: :not_started\n  :proceedings:\n    :PB003:\n      :name: Emergency protection order - extend\n      :tasks:\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :children_proceeding\n        dependencies: *3\n        state: :waiting_for_dependency\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :client_relationship_to_proceeding\n        dependencies: *4\n        state: :complete\n    :PB007:\n      :name: Emergency protection order - discharge\n      :tasks:\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :children_proceeding\n        dependencies: *5\n        state: :waiting_for_dependency\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :client_relationship_to_proceeding\n        dependencies: *6\n        state: :complete\n",
    dry_run_output: <<~STRING,
      {affected: 1,
       submitted: 0,
       answered: 1,
       fixable: 0,
       investigate: 1,
       migrated: 0,
       data:
        [{id: "#{legal_aid_application.id}",
          ref: "#{legal_aid_application.application_ref}",
          proceedings: 2,
          proceeding_states: [:complete],
          proceeding_answers: ["biological", "court_order"]}]}
    STRING
    live_output: <<~STRING,
      {affected: 1,
       submitted: 0,
       answered: 1,
       fixable: 0,
       investigate: 1,
       migrated: 0,
       data:
        [{id: "#{legal_aid_application.id}",
          ref: "#{legal_aid_application.application_ref}",
          proceedings: 2,
          proceeding_states: [:complete],
          proceeding_answers: ["biological", "court_order"],
          fixed: false}]}
    STRING
  }
end

def double_proceeding_submitted_with_mis_matched_answered_question
  {
    task_list: "--- !ruby/object:LegalFramework::SerializableMeritsTaskList\nlfa_response:\n  :request_id: 42ef6c04-2bf7-49e7-beae-48cc63e5cd6e\n  :success: true\n  :application:\n    :tasks:\n      :opponent_name: &1 []\n      :children_application: &2 []\n  :proceedings:\n  - :ccms_code: PB003\n    :tasks:\n      :children_proceeding: &3\n      - children_application\n      :client_relationship_to_proceeding: &4 []\n  - :ccms_code: PB007\n    :tasks:\n      :children_proceeding: &5\n      - children_application\n      :client_relationship_to_proceeding: &6 []\ntasks:\n  :application:\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :opponent_name\n    dependencies: *1\n    state: :not_started\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :children_application\n    dependencies: *2\n    state: :not_started\n  :proceedings:\n    :PB003:\n      :name: Emergency protection order - extend\n      :tasks:\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :children_proceeding\n        dependencies: *3\n        state: :waiting_for_dependency\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :client_relationship_to_proceeding\n        dependencies: *4\n        state: :complete\n    :PB007:\n      :name: Emergency protection order - discharge\n      :tasks:\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :children_proceeding\n        dependencies: *5\n        state: :waiting_for_dependency\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :client_relationship_to_proceeding\n        dependencies: *6\n        state: :complete\n",
    dry_run_output: <<~STRING,
      {affected: 1,
       submitted: 1,
       answered: 1,
       fixable: 0,
       investigate: 1,
       migrated: 0,
       data:
        [{id: "#{legal_aid_application.id}",
          ref: "#{legal_aid_application.application_ref}",
          proceedings: 2,
          proceeding_states: [:complete],
          proceeding_answers: ["biological", "court_order"]}]}
    STRING
    live_output: <<~STRING,
      {affected: 1,
       submitted: 1,
       answered: 1,
       fixable: 0,
       investigate: 1,
       migrated: 0,
       data:
        [{id: "#{legal_aid_application.id}",
          ref: "#{legal_aid_application.application_ref}",
          proceedings: 2,
          proceeding_states: [:complete],
          proceeding_answers: ["biological", "court_order"],
          fixed: false}]}
    STRING
  }
end
