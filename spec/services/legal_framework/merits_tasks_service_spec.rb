require "rails_helper"

module LegalFramework
  RSpec.describe MeritsTasksService do
    let(:application) { create(:legal_aid_application, :with_proceedings) }
    let(:service) { described_class.call(application) }
    let(:submission) { create(:legal_framework_submission) }

    before do
      double MeritsTasksRetrieverService, submission: submission
      allow(MeritsTasksRetrieverService).to receive(:call).with(any_args).and_return(dummy_response_hash)
    end

    describe "#call" do
      it "calls the MeritsTasksRetrieverService" do
        service
        expect(MeritsTasksRetrieverService).to have_received(:call)
      end

      it "adds a new submission record" do
        expect { service }.to change(Submission, :count).by(1)
      end

      it "adds a merits task list record" do
        expect { service }.to change(MeritsTaskList, :count).by(1)
      end

      context "merits task list exist" do
        before do
          described_class.call(application)
        end

        it "does not add a new merits task list record" do
          expect { service }.not_to change(MeritsTaskList, :count)
        end

        it "updates the existing merits task list" do
          merits_task_list = MeritsTaskList.first
          expect {
            service
            merits_task_list.reload
          }.to change(merits_task_list, :updated_at)
        end
      end

      context "when a new question is returned by LFA that we cannot handle" do
        before do
          allow(Setting).to receive(:enable_loop?).and_return(enable_loop)
          allow(MeritsTasksRetrieverService).to receive(:call).with(any_args).and_return(work_in_progress_response_hash)
        end

        context "and the enable_loop feature flag is off" do
          let(:enable_loop) { false }
          let(:expected_application_tasks) do
            [
              { name: :nature_of_urgency, state: :ignored },
              { name: :latest_incident_details, state: :not_started },
              { name: :opponent_name, state: :not_started },
              { name: :opponent_mental_capacity, state: :not_started },
              { name: :domestic_abuse_summary, state: :not_started },
              { name: :children_application, state: :not_started },
              { name: :new_question_from_lfa, state: :ignored },
            ]
          end

          let(:expected_proceeding_tasks) do
            [
              { name: :chances_of_success, state: :not_started },
              { name: :new_proceeding_question_from_lfa, state: :ignored },
            ]
          end

          it "section 8 and unknown tasks are marked as ignore" do
            expect(service.tasks[:application].map { |task| { name: task.name, state: task.state } }).to eq expected_application_tasks
            expect(service.tasks[:proceedings][:DA001][:tasks].map { |task| { name: task.name, state: task.state } }).to eq expected_proceeding_tasks
          end
        end

        context "and the enable_loop feature flag is on" do
          let(:enable_loop) { true }
          let(:expected_application_tasks) do
            [
              { name: :nature_of_urgency, state: :not_started },
              { name: :latest_incident_details, state: :not_started },
              { name: :opponent_name, state: :not_started },
              { name: :opponent_mental_capacity, state: :not_started },
              { name: :domestic_abuse_summary, state: :not_started },
              { name: :children_application, state: :not_started },
              { name: :new_question_from_lfa, state: :ignored },
            ]
          end

          it "section 8 task is shown but unknown tasks are still marked as ignore" do
            expect(service.tasks[:application].map { |task| { name: task.name, state: task.state } }).to eq expected_application_tasks
          end
        end
      end

      context "error is raised" do
        before do
          allow(MeritsTasksRetrieverService).to receive(:call).with(any_args).and_raise(SubmissionError, "failed submission")
        end

        it "captures error and returns false" do
          expect(AlertManager).to receive(:capture_exception).with(LegalFramework::SubmissionError)
          service
        end
      end
    end

    def dummy_response_hash
      {
        request_id: submission.id,
        application: {
          tasks: {
            latest_incident_details: [],
            opponent_name: [],
            opponent_mental_capacity: [],
            domestic_abuse_summary: [],
            children_application: [],
          },
        },
        proceedings: [
          {
            ccms_code: application.proceedings.first.ccms_code,
            tasks: {
              chances_of_success: [], # the merits tasks for this one proceeding type, and any dependencies
            },
          },
        ],
      }
    end

    def work_in_progress_response_hash
      {
        request_id: submission.id,
        application: {
          tasks: {
            nature_of_urgency: [], # This has been created in LFA but should only be shown when the enable_loop flag is set
            latest_incident_details: [],
            opponent_name: [],
            opponent_mental_capacity: [],
            domestic_abuse_summary: [],
            children_application: [],
            new_question_from_lfa: [], # This has been created in LFA but is not yet handled by a controller in Apply
          },
        },
        proceedings: [
          {
            ccms_code: application.proceedings.first.ccms_code,
            tasks: {
              chances_of_success: [], # the merits tasks for this one proceeding type, and any dependencies
              new_proceeding_question_from_lfa: [], # This has been created in LFA but is not yet handled by a controller in Apply
            },
          },
        ],
      }
    end

    def updated_response_hash
      dummy_response_hash[:proceeding_types].first[:tasks][:chances_of_success]
    end
  end
end
