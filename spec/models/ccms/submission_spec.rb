require 'rails_helper'

module CCMS
  RSpec.describe Submission do

    let(:legal_aid_application)  { create :legal_aid_application }
    context 'Validations' do
      it 'errors if no legal aid application id is present' do
        sub = Submission.new
        expect(sub).not_to be_valid
        expect(sub.errors[:legal_aid_application_id]).to eq ["can't be blank"]
      end
    end

    describe 'initial state' do
      it 'puts new records into the initial state' do
        sub = Submission.create(legal_aid_application: legal_aid_application)
        expect(sub.aasm_state).to eq 'initialised'
      end
    end

    describe '#process' do
      context 'initialised state' do
        let(:submission) { create :submission, :initialised, legal_aid_application: legal_aid_application }
        context 'operation successful' do
          let(:response) { File.read(File.join(Rails.root, 'spec', 'services', 'ccms', 'data', 'get_reference_data_response.xml')) }
          let(:requestor) { ReferenceDataRequestor.new }

          before do
            allow(submission).to receive(:reference_data_requestor).and_return(requestor)
            expect(requestor).to receive(:transaction_request_id).and_return('20190301030405123456')
            expect(requestor).to receive(:call).and_return(response)
          end

          it 'stores the reference number' do
            submission.process!
            expect(submission.case_ccms_reference).to eq '300000135140'
          end

          it 'changes the state to case_ref_obtained' do
            submission.process!
            expect(submission.aasm_state).to eq 'case_ref_obtained'
          end
        end

        context 'operation in error' do
          before do
            requestor_double = double ReferenceDataRequestor
            allow(requestor_double).to receive(:transaction_request_id).and_return('876876878')
            allow(submission).to receive(:reference_data_requestor).and_return(requestor_double)
            expect(requestor_double).to receive(:call).and_raise(RuntimeError, 'oops')
          end

          it 'puts it into failed state' do
            submission.process!
            expect(submission.aasm_state).to eq 'failed'
          end
          # it records the error in the submission history
        end
      end
    end
  end
end
