require 'rails_helper'

RSpec.describe CCMS::ObtainCaseReferenceService do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:submission) { create :submission, legal_aid_application: legal_aid_application }
  let(:history) { CCMS::SubmissionHistory.find_by(submission_id: submission.id) }
  let(:reference_data_request) { ccms_data_from_file 'reference_data_request.xml' }
  let(:reference_data_requestor) { double CCMS::ReferenceDataRequestor }
  subject { described_class.new(submission) }

  before do
    allow(subject).to receive(:reference_data_requestor).and_return(reference_data_requestor)
  end

  context 'operation successful' do
    let(:reference_data_response) { ccms_data_from_file 'reference_data_response.xml' }
    let(:transaction_request_id_in_example_response) { '20190301030405123456' }
    let(:ccms_case_ref_in_example_response) { '300000135140' }

    before do
      allow(reference_data_requestor).to receive(:formatted_xml).and_return(reference_data_request)
      expect(reference_data_requestor).to receive(:transaction_request_id).and_return(transaction_request_id_in_example_response)
      expect(reference_data_requestor).to receive(:call).and_return(reference_data_response)
    end

    it 'stores the reference number' do
      subject.call
      expect(submission.case_ccms_reference).to eq ccms_case_ref_in_example_response
    end

    it 'changes the state to case_ref_obtained' do
      subject.call
      expect(submission.aasm_state).to eq 'case_ref_obtained'
    end

    it 'writes a history record' do
      expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
      expect(history.from_state).to eq 'initialised'
      expect(history.to_state).to eq 'case_ref_obtained'
      expect("<?xml version=\'1.0\' encoding=\'UTF-8\'?>\n"+history.request).to eq reference_data_request
      expect(history.request).to_not be_nil
      expect(history.success).to be true
      expect(history.details).to be_nil
    end
  end

  context 'operation in error' do
    before do
      allow(reference_data_requestor).to receive(:formatted_xml).and_return(reference_data_request)
      allow(reference_data_requestor).to receive(:transaction_request_id).and_return(Faker::Number.number(digits: 8))
      expect(reference_data_requestor).to receive(:call).and_raise(CCMS::CcmsError, 'oops')
    end

    it 'puts it into failed state' do
      subject.call
      expect(submission.aasm_state).to eq 'failed'
    end

    it 'records the error in the submission history' do
      expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
      expect(history.from_state).to eq 'initialised'
      expect(history.to_state).to eq 'failed'
      expect("<?xml version=\'1.0\' encoding=\'UTF-8\'?>\n"+history.request).to eq reference_data_request
      expect(history.request).to_not be_nil
      expect(history.success).to be false
      expect(history.details).to match(/CCMS::CcmsError/)
      expect(history.details).to match(/oops/)
    end
  end

  # private method tested here because it is mocked out above
  #
  describe '#reference_data_requestor' do
    let(:service_double) { CCMS::ObtainCaseReferenceService.new(submission) }
    let(:requestor1) { service_double.__send__(:reference_data_requestor) }
    let(:requestor2) { service_double.__send__(:reference_data_requestor) }
    it 'only instantiates one copy of the ReferenceDataRequestor' do
      expect(requestor1).to be_instance_of(CCMS::ReferenceDataRequestor)
      expect(requestor1).to eq requestor2
    end
  end
end
