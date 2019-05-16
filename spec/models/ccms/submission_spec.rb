require 'rails_helper'

module CCMS
  RSpec.describe Submission do
    let(:submission) { create :submission }

    context 'Validations' do
      it 'errors if no legal aid application id is present' do
        submission.legal_aid_application = nil
        expect(submission).not_to be_valid
        expect(submission.errors[:legal_aid_application_id]).to eq ["can't be blank"]
      end
    end

    describe 'initial state' do
      it 'puts new records into the initial state' do
        expect(submission.aasm_state).to eq 'initialised'
      end
    end

    describe '#process' do
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
        after(:each) do
          submission.process!
        end

        context 'initialised state' do
          let(:obtain_case_reference_service_double) { ObtainCaseReferenceService.new(submission) }
          it 'calls the obtain_case_reference service' do
            expect(ObtainCaseReferenceService).to receive(:new).with(submission).and_return(obtain_case_reference_service_double)
            expect(obtain_case_reference_service_double).to receive(:call).with(no_args)
          end
        end

        context 'case_ref_obtained state' do
          let(:obtain_applicant_reference_service_double) { ObtainApplicantReferenceService.new(submission) }
          let(:submission) { create :submission, :case_ref_obtained }
          it 'calls the obtain_applicant_reference service' do
            expect(ObtainApplicantReferenceService).to receive(:new).with(submission).and_return(obtain_applicant_reference_service_double)
            expect(obtain_applicant_reference_service_double).to receive(:call).with(no_args)
          end
        end

        context 'applicant_submitted state' do
          let(:check_applicant_status_service_double) { CheckApplicantStatusService.new(submission) }
          let(:submission) { create :submission, :applicant_submitted }
          it 'calls the check_applicant_status service' do
            expect(CheckApplicantStatusService).to receive(:new).with(submission).and_return(check_applicant_status_service_double)
            expect(check_applicant_status_service_double).to receive(:call).with(no_args)
          end
        end

        context 'applicant_ref_obtained state' do
          let(:add_case_service_double) { AddCaseService.new(submission) }
          let(:submission) { create :submission, :applicant_ref_obtained }
          it 'calls the add_case service' do
            expect(AddCaseService).to receive(:new).with(submission).and_return(add_case_service_double)
            expect(add_case_service_double).to receive(:call).with(no_args)
          end
        end
      end
    end
  end
end
