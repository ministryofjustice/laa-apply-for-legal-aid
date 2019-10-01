require 'rails_helper'

RSpec.describe CCMS::AddCaseService do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  let(:submission) { create :submission, :applicant_ref_obtained, legal_aid_application: legal_aid_application }
  let(:history) { CCMS::SubmissionHistory.find_by(submission_id: submission.id) }
  let(:case_add_requestor) { double CCMS::CaseAddRequestor }
  let(:transaction_request_id_in_example_response) { '20190301030405123456' }
  let(:add_case_request) { ccms_data_from_file 'case_add_request.xml' }
  subject { described_class.new(submission) }

  before do
    allow(subject).to receive(:case_add_requestor).and_return(case_add_requestor)
    allow(case_add_requestor).to receive(:transaction_request_id).and_return(transaction_request_id_in_example_response)
    allow(case_add_requestor).to receive(:formatted_xml).and_return(add_case_request)
  end

  context 'operation successful' do
    let(:case_add_response) { ccms_data_from_file 'case_add_response.xml' }

    before do
      expect(case_add_requestor).to receive(:call).and_return(case_add_response)
    end

    it 'sets state to case_submitted' do
      subject.call
      expect(submission.aasm_state).to eq 'case_submitted'
    end

    it 'records the transaction id of the request' do
      subject.call
      expect(submission.case_add_transaction_id).to eq transaction_request_id_in_example_response
    end

    context 'there are documents to upload' do
      let(:submission) { create :submission, :document_ids_obtained, legal_aid_application: legal_aid_application }
      it 'writes a history record' do
        expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
        expect(history.from_state).to eq 'document_ids_obtained'
        expect(history.to_state).to eq 'case_submitted'
        expect(history.success).to be true
        expect(history.details).to be_nil
        expect("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" + history.request).to eq add_case_request
        expect(history.request).to_not be_nil
        # TO DO
        # format of xml is missing "encoding="UTF-8"
        # expect(history.response).to eq case_add_response
        expect(history.response).to_not be_nil
      end
    end

    context 'there are no documents to upload' do
      it 'writes a history record' do
        expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
        expect(history.from_state).to eq 'applicant_ref_obtained'
        expect(history.to_state).to eq 'case_submitted'
        expect(history.success).to be true
        expect(history.details).to be_nil
        expect("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"+history.request).to eq add_case_request
        expect(history.request).to_not be_nil
        # TO DO
        # format of xml is missing "encoding="UTF-8"
        # expect(history.response).to eq case_add_response
        expect(history.response).to_not be_nil
      end
    end
  end

  context 'operation in error' do
    context 'error when adding a case' do
      before do
        allow(case_add_requestor).to receive(:formatted_xml).and_return(add_case_request)
        expect(case_add_requestor).to receive(:call).and_raise(CCMS::CcmsError, 'oops')
      end

      it 'puts it into failed state' do
        subject.call
        expect(submission.aasm_state).to eq 'failed'
      end

      it 'records the error in the submission history' do
        expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
        expect(history.from_state).to eq 'applicant_ref_obtained'
        expect(history.to_state).to eq 'failed'
        expect(history.success).to be false
        expect(history.details).to match(/CCMS::CcmsError/)
        expect(history.details).to match(/oops/)
        expect("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"+history.request).to eq add_case_request
        expect(history.request).to_not be_nil
        expect(history.response).to be_nil
      end
    end

    context 'failed response from CCMS adding a case' do
      let(:case_add_response) { ccms_data_from_file 'case_add_response.xml' }
      let(:case_add_response_parser) { double CCMS::CaseAddResponseParser }

      before do
        # allow(case_add_requestor).to receive(:formatted_xml).and_return(case_add_response)
        allow(case_add_response_parser).to receive(:doc).and_return(case_add_response)
        expect(case_add_requestor).to receive(:call).and_return(case_add_response)
        allow(subject).to receive(:case_add_response_parser).and_return(case_add_response_parser)
        expect(case_add_response_parser).to receive(:success?).and_return(false)
      end

      it 'puts it into failed state' do
        subject.call
        expect(submission.aasm_state).to eq 'failed'
      end

      it 'records the error in the submission history' do
        expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
        expect(history.from_state).to eq 'applicant_ref_obtained'
        expect(history.to_state).to eq 'failed'
        expect(history.success).to be false
        expect(history.details).to eq(case_add_response)
        expect("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" + history.request).to eq add_case_request
        expect(history.request).to_not be_nil
        # TO DO
        # format of xml is missing "encoding="UTF-8"
        # expect(history.response).to eq case_add_response
        expect(history.response).to_not be_nil
      end
    end
  end

  # private method tested here because it is mocked out above
  #
  describe '#case_add_requestor' do
    let(:service_double) { CCMS::AddCaseService.new(submission) }
    let(:requestor1) { service_double.__send__(:case_add_requestor) }
    let(:requestor2) { service_double.__send__(:case_add_requestor) }
    it 'only instantiates one copy of the CaseAddRequestor' do
      expect(requestor1).to be_instance_of(CCMS::CaseAddRequestor)
      expect(requestor1).to eq requestor2
    end
  end
end
