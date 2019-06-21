require 'rails_helper'
require 'sidekiq/testing'

module CCMS # rubocop:disable Metrics/ModuleLength
  RSpec.describe Submission do
    let(:state) { :initialised }
    let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
    let(:submission) { create :submission, legal_aid_application: legal_aid_application, aasm_state: state }

    context 'Validations' do
      it 'errors if no legal aid application id is present' do
        submission.legal_aid_application = nil
        expect(submission).not_to be_valid
        expect(submission.errors[:legal_aid_application_id]).to eq ["can't be blank"]
      end
    end

    describe 'initial state' do
      let(:submission) { create :submission }
      it 'puts new records into the initial state' do
        expect(submission.aasm_state).to eq 'initialised'
      end
    end

    describe '#process!' do
      let(:history) { SubmissionHistory.find_by(submission_id: submission.id) }

      context 'invalid state' do
        it 'raises if state is invalid' do
          submission.aasm_state = 'xxxxx'
          expect {
            submission.process!
          }.to raise_error CcmsError, 'Unknown state'
        end
      end

      context 'valid state' do
        let(:service) { ObtainCaseReferenceService }
        let(:service_instance) { service.new(submission) }

        before do
          allow(service).to receive(:new).with(submission).and_return(service_instance)
        end

        after { submission.process! }

        it 'calls the obtain_case_reference service' do
          expect(service_instance).to receive(:call).with(no_args)
        end

        context 'case_ref_obtained state' do
          let(:state) { :case_ref_obtained }
          let(:service) { ObtainApplicantReferenceService }
          it 'calls the obtain_applicant_reference service' do
            expect(service_instance).to receive(:call).with(no_args)
          end
        end

        context 'applicant_submitted state' do
          let(:state) { :applicant_submitted }
          let(:service) { CheckApplicantStatusService }
          it 'calls the check_applicant_status service' do
            expect(service_instance).to receive(:call).with(no_args)
          end
        end

        context 'applicant_ref_obtained state' do
          let(:state) { :applicant_ref_obtained }
          let(:service) { AddCaseService }
          it 'calls the add_case service' do
            expect(service_instance).to receive(:call).with(no_args)
          end
        end

        context 'case_submitted state' do
          let(:state) { :case_submitted }
          let(:service) { CheckCaseStatusService }
          it 'calls the check_case_status service' do
            expect(service_instance).to receive(:call).with(no_args)
          end
        end

        context 'case_created state' do
          let(:state) { :case_created }
          let(:service) { ObtainDocumentIdService }
          it 'calls the obtain_document_id service' do
            expect(service_instance).to receive(:call).with(no_args)
          end
        end

        context 'document_ids_obtained state' do
          let(:state) { :document_ids_obtained }
          let(:service) { UploadDocumentsService }
          it 'calls the upload_documents service' do
            expect(service_instance).to receive(:call).with(no_args)
          end
        end
      end
    end

    context 'state change:' do
      describe '#obtain_case_ref' do
        it 'changes state' do
          expect { submission.obtain_case_ref }.to change { submission.aasm_state }.to('case_ref_obtained')
        end

        Sidekiq::Testing.fake! do
          it 'triggers a worker to start the next step' do
            expect { submission.obtain_case_ref }.to change { SubmissionProcessWorker.jobs.size }.by(1)
          end
        end

        context 'with event fail' do
          it 'changes state' do
            expect { submission.fail }.to change { submission.aasm_state }.to('failed')
          end

          Sidekiq::Testing.fake! do
            it 'does not triggers a worker' do
              expect { submission.fail }.not_to change { SubmissionProcessWorker.jobs.size }
            end
          end
        end

        context 'with event complete' do
          let(:state) { :case_created }
          it 'changes state' do
            expect { submission.complete }.to change { submission.aasm_state }.to('completed')
          end

          Sidekiq::Testing.fake! do
            it 'does not triggers a worker' do
              expect { submission.fail }.not_to change { SubmissionProcessWorker.jobs.size }
            end
          end
        end
      end
    end
  end
end
