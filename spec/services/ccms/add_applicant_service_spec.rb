require 'rails_helper'

RSpec.describe CCMS::AddApplicantService do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  let(:submission) { create :submission, :case_ref_obtained, legal_aid_application: legal_aid_application }
  let(:history) { CCMS::SubmissionHistory.find_by(submission_id: submission.id) }
  let(:applicant_add_requestor) { double CCMS::ApplicantAddRequestor }
  subject { described_class.new(submission) }

  before do
    allow(subject).to receive(:applicant_add_requestor).and_return(applicant_add_requestor)
  end

  context 'operation successful' do
    context 'no applicant exists on the CCMS system' do
      let(:applicant_add_response) { ccms_data_from_file 'applicant_add_response_success.xml' }
      let(:transaction_request_id_in_example_response) { '20190301030405123456' }

      before do
        expect(applicant_add_requestor).to receive(:call).and_return(applicant_add_response)
        allow(applicant_add_requestor).to receive(:transaction_request_id).and_return(transaction_request_id_in_example_response)
      end

      it 'sets state to applicant_submitted' do
        subject.call
        expect(submission.aasm_state).to eq 'applicant_submitted'
      end

      it 'records the transaction id of the request' do
        subject.call
        expect(submission.applicant_add_tx_id).to eq transaction_request_id_in_example_response
      end

      it 'writes a history record' do
        expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
        expect(history.from_state).to eq 'case_ref_obtained'
        expect(history.to_state).to eq 'applicant_submitted'
        expect(history.success).to be true
        expect(history.details).to be_nil
      end
    end
  end

  context 'operation in error' do
    context 'error when adding an applicant' do
      before do
        expect(applicant_add_requestor).to receive(:call).and_raise(RuntimeError, 'oops')
      end

      it 'puts it into failed state' do
        subject.call
        expect(submission.aasm_state).to eq 'failed'
      end

      it 'records the error in the submission history' do
        expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
        expect(history.from_state).to eq 'case_ref_obtained'
        expect(history.to_state).to eq 'failed'
        expect(history.success).to be false
        expect(history.details).to match(/RuntimeError/)
        expect(history.details).to match(/oops/)
      end
    end

    context 'failed response from CCMS adding an applicant' do
      let(:applicant_add_response) { ccms_data_from_file 'applicant_add_response_failure.xml' }
      let(:transaction_request_id_in_example_response) { '20190301030405123456' }

      before do
        expect(applicant_add_requestor).to receive(:call).and_return(applicant_add_response)
        expect(applicant_add_requestor).to receive(:transaction_request_id).and_return(transaction_request_id_in_example_response)
      end

      it 'puts it into failed state' do
        subject.call
        expect(submission.aasm_state).to eq 'failed'
      end

      it 'records the error in the submission history' do
        expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
        expect(history.from_state).to eq 'case_ref_obtained'
        expect(history.to_state).to eq 'failed'
        expect(history.success).to be false
        expect(history.details).to eq(applicant_add_response)
      end
    end
  end

  # private method tested here because it is mocked out above
  #
  describe '#applicant_add_requestor' do
    let(:service_double) { CCMS::AddApplicantService.new(submission) }
    let(:requestor1) { service_double.__send__(:applicant_add_requestor) }
    let(:requestor2) { service_double.__send__(:applicant_add_requestor) }
    it 'only instantiates one copy of the ApplicantAddRequestor' do
      expect(requestor1).to be_instance_of(CCMS::ApplicantAddRequestor)
      expect(requestor1.object_id).to eq requestor2.object_id
    end
  end
end
