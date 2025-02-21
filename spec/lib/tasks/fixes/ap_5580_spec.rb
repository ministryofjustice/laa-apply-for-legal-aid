require "rails_helper"

RSpec.describe "ap_5580:", type: :task do
  subject(:task) do
    Rake::Task["fixes:ap_5580"]
  end

  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    allow(Rails.logger).to receive(:info)
    allow($stdout).to receive(:write) # comment this out if using binding.pry in this file
    create(:legal_framework_merits_task_list, serialized_data:, legal_aid_application:)
    create(:proceeding, :pb007, legal_aid_application:, relationship_to_child: "biological")
  end

  let(:legal_aid_application) do
    travel_to Date.parse("2025-02-21") do
      create(:legal_aid_application, :with_applicant)
    end
  end
  let(:proceedings) { legal_aid_application.proceedings }

  describe "dry-run of fixes:ap_5580" do
    context "when there is an application with a two proceedings and both have an unanswered question" do
      let(:serialized_data) { double_proceeding_with_question[:input] }

      it "logs the message" do
        expect { task.execute }.to output(double_proceeding_with_question[:output]).to_stdout
      end

      it "does not affect the tasks" do
        task.execute
        expect(legal_aid_application.legal_framework_merits_task_list).to have_task_in_state(:PB004, :client_relationship_to_proceeding, :not_started)
        expect(legal_aid_application.legal_framework_merits_task_list).to have_task_in_state(:PB005, :client_relationship_to_proceeding, :not_started)
        expect(legal_aid_application.legal_framework_merits_task_list).not_to have_task_in_state(:application, :client_relationship_to_children, :not_started)
      end
    end

    context "when there is an application with a single proceeding with an unanswered question" do
      let(:serialized_data) { single_proceeding_with_question[:input] }

      it "logs the message" do
        expect { task.execute }.to output(single_proceeding_with_question[:output]).to_stdout
      end

      it "does not affect the tasks" do
        task.execute
        expect(legal_aid_application.legal_framework_merits_task_list).to have_task_in_state(:PB057, :client_relationship_to_proceeding, :not_started)
        expect(legal_aid_application.legal_framework_merits_task_list).not_to have_task_in_state(:application, :client_relationship_to_children, :not_started)
      end
    end

    context "when there is an application with a single proceeding with an answered question" do
      let(:serialized_data) { single_proceeding_with_answered_question[:input] }

      it "logs the message" do
        expect { task.execute }.to output(single_proceeding_with_answered_question[:output]).to_stdout
      end

      it "does not affect the tasks" do
        task.execute
        expect(legal_aid_application.legal_framework_merits_task_list).to have_task_in_state(:PB057, :client_relationship_to_proceeding, :complete)
        expect(legal_aid_application.legal_framework_merits_task_list).not_to have_task_in_state(:application, :client_relationship_to_children, :not_started)
      end
    end

    context "when there is an application with no proceeding" do
      let(:serialized_data) { single_proceeding_without_question[:input] }

      it "logs the message" do
        expect { task.execute }.to output(single_proceeding_without_question[:output]).to_stdout
      end
    end
  end

  describe "live run of fixes:ap_5580" do
    context "when there is an application with a two proceedings and both have an unanswered question" do
      let(:serialized_data) { double_proceeding_with_question[:input] }

      it "logs the message" do
        expect { task.execute(dry_run: false) }.to output(double_proceeding_with_question[:update_output]).to_stdout
      end

      it "creates the new task" do
        task.execute(dry_run: false)

        expect(legal_aid_application.legal_framework_merits_task_list).not_to have_task_in_state(:PB004, :client_relationship_to_proceeding, :not_started)
        expect(legal_aid_application.legal_framework_merits_task_list).not_to have_task_in_state(:PB005, :client_relationship_to_proceeding, :not_started)
        expect(legal_aid_application.legal_framework_merits_task_list).to have_task_in_state(:application, :client_relationship_to_children, :not_started)
      end

      it "copies the answer to the applicant" do
        task.execute(dry_run: false)
        expect(legal_aid_application.applicant.reload.relationship_to_children).to eq proceedings.map(&:relationship_to_child).uniq.first
      end
    end

    context "when there is an application with a single proceeding with an unanswered question" do
      let(:serialized_data) { single_proceeding_with_question[:input] }

      it "logs the message" do
        expect { task.execute(dry_run: false) }.to output(single_proceeding_with_question[:update_output]).to_stdout
      end

      it "creates the new task" do
        task.execute(dry_run: false)
        expect(legal_aid_application.legal_framework_merits_task_list).not_to have_task_in_state(:PB057, :client_relationship_to_proceeding, :not_started)
        expect(legal_aid_application.legal_framework_merits_task_list).to have_task_in_state(:application, :client_relationship_to_children, :not_started)
      end

      it "copies the answer to the applicant" do
        task.execute(dry_run: false)
        expect(legal_aid_application.applicant.reload.relationship_to_children).to eq proceedings.map(&:relationship_to_child).uniq.first
      end
    end

    context "when there is an application with a single proceeding with an answered question" do
      let(:serialized_data) { single_proceeding_with_answered_question[:input] }

      it "logs the message" do
        expect { task.execute(dry_run: false) }.to output(single_proceeding_with_answered_question[:output]).to_stdout
      end

      it "does not affect the tasks" do
        task.execute(dry_run: false)
        expect(legal_aid_application.legal_framework_merits_task_list).to have_task_in_state(:PB057, :client_relationship_to_proceeding, :complete)
        expect(legal_aid_application.legal_framework_merits_task_list).not_to have_task_in_state(:application, :client_relationship_to_children, :not_started)
      end
    end

    context "when there is an application with no proceeding" do
      let(:serialized_data) { single_proceeding_without_question[:input] }

      it "logs the message" do
        expect { task.execute(dry_run: false) }.to output(single_proceeding_without_question[:output]).to_stdout
      end

      it "does not affect the tasks" do
        task.execute
        expect(legal_aid_application.legal_framework_merits_task_list).not_to have_task_in_state(:application, :client_relationship_to_children, :not_started)
      end
    end
  end
end

def single_proceeding_without_question
  {
    input: "--- !ruby/object:LegalFramework::SerializableMeritsTaskList\nlfa_response:\n  :request_id: 7ebd1d6d-a3be-4151-a5db-c8ece94c72ff\n  :success: true\n  :application:\n    :tasks:\n      :opponent_name: &1 []\n      :children_application: &2 []\n  :proceedings:\n  - :ccms_code: PB057\n    :tasks:\n      :children_proceeding: &3 []\ntasks:\n  :application:\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :opponent_name\n    dependencies: *1\n    state: :complete\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :children_application\n    dependencies: *2\n    state: :complete\n  :proceedings:\n    :PB057:\n      :name: Care order\n      :tasks:\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :children_proceeding\n        dependencies: *3\n        state: :complete",
    output: "{total: 0, discarded: 0, completed: 0, issues: 0, fixes: 0, data: []}\n",
  }
end

def single_proceeding_with_question
  {
    input: "--- !ruby/object:LegalFramework::SerializableMeritsTaskList\nlfa_response:\n  :request_id: 7ebd1d6d-a3be-4151-a5db-c8ece94c72ff\n  :success: true\n  :application:\n    :tasks:\n      :opponent_name: &1 []\n      :children_application: &2 []\n  :proceedings:\n  - :ccms_code: PB057\n    :tasks:\n      :children_proceeding: &3 []\n      :client_relationship_to_proceeding: &4 []\ntasks:\n  :application:\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :opponent_name\n    dependencies: *1\n    state: :complete\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :children_application\n    dependencies: *2\n    state: :complete\n  :proceedings:\n    :PB057:\n      :name: Care order\n      :tasks:\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :children_proceeding\n        dependencies: *3\n        state: :complete\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :client_relationship_to_proceeding\n        dependencies: *4\n        state: :not_started\n",
    output: <<~STRING,
      {total: 1,
       discarded: 0,
       completed: 0,
       issues: 1,
       fixes: 0,
       data:
        [["#{legal_aid_application.id}",
          "#{legal_aid_application.application_ref}",
          1,
          :PB057,
          :not_started,
          "fixable"]]}
    STRING
    update_output: <<~STRING,
      {total: 1,
       discarded: 0,
       completed: 0,
       issues: 1,
       fixes: 1,
       data: [["#{legal_aid_application.id}", "#{legal_aid_application.application_ref}", 1, "fixed"]]}
    STRING
  }
end

def single_proceeding_with_answered_question
  {
    input: "--- !ruby/object:LegalFramework::SerializableMeritsTaskList\nlfa_response:\n  :request_id: 7ebd1d6d-a3be-4151-a5db-c8ece94c72ff\n  :success: true\n  :application:\n    :tasks:\n      :opponent_name: &1 []\n      :children_application: &2 []\n  :proceedings:\n  - :ccms_code: PB057\n    :tasks:\n      :children_proceeding: &3 []\n      :client_relationship_to_proceeding: &4 []\ntasks:\n  :application:\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :opponent_name\n    dependencies: *1\n    state: :complete\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :children_application\n    dependencies: *2\n    state: :complete\n  :proceedings:\n    :PB057:\n      :name: Care order\n      :tasks:\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :children_proceeding\n        dependencies: *3\n        state: :complete\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :client_relationship_to_proceeding\n        dependencies: *4\n        state: :complete\n",
    output: <<~STRING,
      {total: 1,
       discarded: 0,
       completed: 1,
       issues: 0,
       fixes: 0,
       data:
        [["#{legal_aid_application.id}",
          "#{legal_aid_application.application_ref}",
          1,
          "no problem, completed",
          "biological"]]}
    STRING
  }
end

def double_proceeding_with_question
  {
    input: "--- !ruby/object:LegalFramework::SerializableMeritsTaskList\nlfa_response:\n  :request_id: 42ef6c04-2bf7-49e7-beae-48cc63e5cd6e\n  :success: true\n  :application:\n    :tasks:\n      :opponent_name: &1 []\n      :children_application: &2 []\n  :proceedings:\n  - :ccms_code: PB004\n    :tasks:\n      :children_proceeding: &3\n      - children_application\n      :client_relationship_to_proceeding: &4 []\n  - :ccms_code: PB005\n    :tasks:\n      :children_proceeding: &5\n      - children_application\n      :client_relationship_to_proceeding: &6 []\ntasks:\n  :application:\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :opponent_name\n    dependencies: *1\n    state: :not_started\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :children_application\n    dependencies: *2\n    state: :not_started\n  :proceedings:\n    :PB004:\n      :name: Emergency protection order - extend\n      :tasks:\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :children_proceeding\n        dependencies: *3\n        state: :waiting_for_dependency\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :client_relationship_to_proceeding\n        dependencies: *4\n        state: :not_started\n    :PB005:\n      :name: Emergency protection order - discharge\n      :tasks:\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :children_proceeding\n        dependencies: *5\n        state: :waiting_for_dependency\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :client_relationship_to_proceeding\n        dependencies: *6\n        state: :not_started\n",
    output: <<~STRING,
      {total: 1,
       discarded: 0,
       completed: 0,
       issues: 1,
       fixes: 0,
       data:
        [["#{legal_aid_application.id}",
          "#{legal_aid_application.application_ref}",
          2,
          :PB004,
          :PB005,
          :not_started,
          "fixable"]]}
    STRING
    update_output: <<~STRING,
      {total: 1,
       discarded: 0,
       completed: 0,
       issues: 1,
       fixes: 1,
       data: [["#{legal_aid_application.id}", "#{legal_aid_application.application_ref}", 2, "fixed"]]}
    STRING
  }
end
