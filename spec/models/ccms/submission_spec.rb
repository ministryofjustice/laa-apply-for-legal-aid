require 'rails_helper'

module CCMS
  RSpec.describe Submission do
    let(:sub) { create :submission }

    context 'Validations' do
      it 'errors if no legal aid application id is present' do
        sub.legal_aid_application = nil
        expect(sub).not_to be_valid
        expect(sub.errors[:legal_aid_application_id]).to eq ["can't be blank"]
      end
    end

    describe 'initial state' do
      it 'puts new records into the initial state' do
        expect(sub.aasm_state).to eq 'initialised'
      end
    end

    describe '#process' do
      let(:history) { SubmissionHistory.find_by(submission_id: submission.id) }

      context 'invalid state' do
        it 'raises if state is invalid' do
          sub.aasm_state = 'xxxxx'
          expect {
            sub.process!
          }.to raise_error RuntimeError, 'Unknown state'
        end
      end

      context 'initialised state' do
        let(:obtain_case_reference_service_double) { ObtainCaseReferenceService.new(sub) }
        it 'calls the obtain_case_reference service' do
          expect(ObtainCaseReferenceService).to receive(:new).with(sub).and_return(obtain_case_reference_service_double)
          expect(obtain_case_reference_service_double).to receive(:call)
          sub.process!
        end
      end

      context 'case_ref_obtained state' do
        let(:submission) { create :submission, :case_ref_obtained }
        let(:obtain_applicant_reference_service_double) { ObtainApplicantReferenceService.new(submission) }
        it 'calls the obtain_applicant_reference service' do
          expect(ObtainApplicantReferenceService).to receive(:new).with(submission).and_return(obtain_applicant_reference_service_double)
          expect(obtain_applicant_reference_service_double).to receive(:call)
          submission.process!
        end
      end
    end
  end
end
