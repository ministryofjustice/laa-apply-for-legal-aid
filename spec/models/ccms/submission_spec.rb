require 'rails_helper'
require 'sidekiq/testing'

module CCMS
  RSpec.describe Submission do
    let(:state) { :initialised }
    let(:applicant_poll_count) { 0 }
    let(:case_poll_count) { 0 }
    let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :with_other_assets_declaration, :with_savings_amount, :submitting_assessment }
    let(:submission) do
      create :submission,
             legal_aid_application: legal_aid_application,
             aasm_state: state,
             applicant_poll_count: applicant_poll_count,
             case_poll_count: case_poll_count
    end

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
          }.to raise_error CCMSError, "Submission #{submission.id} - Unknown state: xxxxx"
        end
      end

      context 'valid state' do
        let(:service) { CCMS::Submitters::ObtainCaseReferenceService }
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
          let(:service) { CCMS::Submitters::ObtainApplicantReferenceService }
          it 'calls the obtain_applicant_reference service' do
            expect(service_instance).to receive(:call).with(no_args)
          end
        end

        context 'applicant_submitted state' do
          let(:state) { :applicant_submitted }
          let(:service) { CCMS::Submitters::CheckApplicantStatusService }
          it 'calls the check_applicant_status service' do
            expect(service_instance).to receive(:call).with(no_args)
          end
        end

        context 'applicant_ref_obtained state' do
          let(:state) { :applicant_ref_obtained }
          let(:service) { CCMS::Submitters::ObtainDocumentIdService }
          it 'calls the add_case service' do
            expect(service_instance).to receive(:call).with(no_args)
          end
        end

        context 'case_submitted state' do
          let(:state) { :case_submitted }
          let(:service) { CCMS::Submitters::CheckCaseStatusService }
          it 'calls the check_case_status service' do
            expect(service_instance).to receive(:call).with(no_args)
          end
        end

        context 'case_created state' do
          let(:state) { :case_created }
          let(:service) { CCMS::Submitters::UploadDocumentsService }
          it 'calls the obtain_document_id service' do
            expect(service_instance).to receive(:call).with(no_args)
          end
        end

        context 'document_ids_obtained state' do
          let(:state) { :document_ids_obtained }
          let(:service) { CCMS::Submitters::AddCaseService }
          it 'calls the upload_documents service' do
            expect(service_instance).to receive(:call).with({})
          end
        end
      end
    end

    context 'state change:' do
      describe '#obtain_case_ref' do
        it 'changes state' do
          expect { submission.obtain_case_ref }.to change { submission.aasm_state }.to('case_ref_obtained')
        end

        context 'with event fail' do
          it 'changes state' do
            expect { submission.fail }.to change { submission.aasm_state }.to('failed')
          end
        end

        context 'with event complete' do
          let(:state) { :case_created }
          it 'changes state' do
            expect { submission.complete }.to change { submission.aasm_state }.to('completed')
          end
        end
      end
    end

    describe '#process_async!' do
      context 'submission is in initialised state' do
        it 'calls SubmissionProcessWorker with a delay of 5 seconds' do
          expect(SubmissionProcessWorker).to receive(:perform_async).with(submission.id, submission.aasm_state)
          submission.process_async!
        end
      end
    end

    describe '#delay' do
      context 'intialised state' do
        it 'returns the base delay' do
          expect(submission.delay).to eq 5.seconds
        end
      end

      context 'applicant_submitted state' do
        let(:state) { 'applicant_submitted' }

        context 'zero poll count' do
          let(:applicant_poll_count) { 0 }
          it 'returns the base delay' do
            expect(submission.delay).to eq 5.seconds
          end
        end

        context 'poll count of 6' do
          let(:applicant_poll_count) { 6 }
          it 'returns 7 times the base delay' do
            expect(submission.delay).to eq 35.seconds
          end
        end
      end

      context 'case_submitted state' do
        let(:state) { 'case_submitted' }

        context 'zero poll count' do
          let(:case_poll_count) { 0 }
          it 'returns the base delay' do
            expect(submission.delay).to eq 5.seconds
          end
        end

        context 'poll count of 6' do
          let(:case_poll_count) { 8 }
          it 'returns 7 times the base delay' do
            expect(submission.delay).to eq 45.seconds
          end
        end
      end
    end
  end
end
