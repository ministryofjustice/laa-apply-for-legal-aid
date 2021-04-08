require 'rails_helper'

module LegalFramework
  RSpec.describe MeritsTasksService do
    let(:application) { create :legal_aid_application, :with_proceeding_types }
    let(:service) { described_class.call(application) }
    let(:submission) { create :legal_framework_submission }

    before do
      double MeritsTasksRetrieverService, submission: submission
      allow(MeritsTasksRetrieverService).to receive(:call).with(any_args).and_return(dummy_response_hash)
    end

    describe '#call' do
      it 'calls the MeritsTasksRetrieverService' do
        service
        expect(MeritsTasksRetrieverService).to have_received(:call)
      end

      it 'adds a new submission record' do
        expect { service }.to change { Submission.count }.by(1)
      end

      it 'adds a merits task list record' do
        expect { service }.to change { MeritsTaskList.count }.by(1)
      end

      context 'merits task list exist' do
        before do
          described_class.call(application)
        end

        it 'does not add a new merits task list record' do
          expect { service }.not_to change { MeritsTaskList.count }
        end

        it 'updates the existing merits task list' do
          merits_task_list = MeritsTaskList.first
          expect {
            service
            merits_task_list.reload
          }.to change(merits_task_list, :updated_at)
        end
      end

      context 'error is raised' do
        before do
          allow(MeritsTasksRetrieverService).to receive(:call).with(any_args).and_raise(SubmissionError, 'failed submission')
        end

        it 'captures error and returns false' do
          expect(Sentry).to receive(:capture_exception).with(LegalFramework::SubmissionError)
          service
        end
      end
    end

    def dummy_response_hash
      {
        request_id: submission.id,
        application: {
          tasks: {
            incident_details: [],
            opponent_details: [],
            application_children: []
          }
        },
        proceeding_types: [
          {
            ccms_code: application.proceeding_types.first.ccms_code,
            tasks: {
              chances_of_success: [] # the merits tasks for this one proceeding type, and any dependencies
            }
          }
        ]
      }
    end

    def updated_response_hash
      dummy_response_hash[:proceeding_types].first[:tasks][:chances_of_success]
    end
  end
end
