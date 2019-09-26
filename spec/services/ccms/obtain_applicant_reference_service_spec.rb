require 'rails_helper'

RSpec.describe CCMS::ObtainApplicantReferenceService do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  let(:submission) { create :submission, :case_ref_obtained, legal_aid_application: legal_aid_application }
  let(:history) { CCMS::SubmissionHistory.find_by(submission_id: submission.id) }
  let(:applicant_search_request) { ccms_data_from_file 'applicant_search_request.xml' }
  let(:applicant_search_requestor) { double CCMS::ApplicantSearchRequestor }
  subject { described_class.new(submission) }

  before do
    allow(subject).to receive(:applicant_search_requestor).and_return(applicant_search_requestor)
  end

  context 'operation successful' do
    before do
      allow(applicant_search_requestor).to receive(:formatted_xml).and_return(applicant_search_request)
      expect(applicant_search_requestor).to receive(:call).and_return(applicant_search_response)
      expect(applicant_search_requestor).to receive(:transaction_request_id).and_return(transaction_request_id_in_example_response)
    end

    context 'applicant exists on the CCMS system' do
      let(:applicant_search_response) { ccms_data_from_file 'applicant_search_response_one_result.xml' }
      let(:transaction_request_id_in_example_response) { '20190301030405123456' }
      let(:applicant_ccms_reference_in_example_response) { '4390016' }

      it 'updates the applicant_ccms_reference' do
        subject.call
        expect(submission.applicant_ccms_reference).to eq applicant_ccms_reference_in_example_response
      end

      it 'sets the state to applicant_ref_obtained' do
        subject.call
        expect(submission.aasm_state).to eq 'applicant_ref_obtained'
      end

      it 'writes a history record' do
        expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
        expect(history.from_state).to eq 'case_ref_obtained'
        expect(history.to_state).to eq 'applicant_ref_obtained'
        expect("<?xml version=\'1.0\' encoding=\'UTF-8\'?>\n"+history.request).to eq applicant_search_request
        expect(history.request).to_not be_nil
        expect(history.success).to be true
        expect(history.details).to be_nil
      end
    end

    context 'applicant does not exist on the CCMS system' do
      let(:applicant_search_response) { ccms_data_from_file 'applicant_search_response_no_results.xml' }
      let(:transaction_request_id_in_example_response) { '20190301030405123456' }
      let(:add_applicant_service_double) { CCMS::AddApplicantService.new(submission) }

      it 'calls the add_applicant_service' do
        expect(CCMS::AddApplicantService).to receive(:new).with(submission).and_return(add_applicant_service_double)
        expect(add_applicant_service_double).to receive(:call)
        subject.call
      end
    end
  end

  context 'operation in error' do
    context 'error when searching for applicant' do
      before do
        allow(applicant_search_requestor).to receive(:formatted_xml).and_return(applicant_search_request)
        allow(applicant_search_requestor).to receive(:transaction_request_id).and_return(Faker::Number.number(digits: 8))
        expect(applicant_search_requestor).to receive(:call).and_raise(CCMS::CcmsError, 'oops')
      end

      it 'puts it into failed state' do
        subject.call
        expect(submission.aasm_state).to eq 'failed'
      end

      it 'records the error in the submission history' do
        expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
        expect(history.from_state).to eq 'case_ref_obtained'
        expect(history.to_state).to eq 'failed'
        expect("<?xml version=\'1.0\' encoding=\'UTF-8\'?>\n"+history.request).to eq applicant_search_request
        expect(history.request).to_not be_nil
        expect(history.success).to be false
        expect(history.details).to match(/CCMS::CcmsError/)
        expect(history.details).to match(/oops/)
      end
    end
  end

  # private method tested here because it is mocked out above
  #
  describe '#applicant_search_requestor' do
    let(:service_double) { CCMS::ObtainApplicantReferenceService.new(submission) }
    let(:requestor1) { service_double.__send__(:applicant_search_requestor) }
    let(:requestor2) { service_double.__send__(:applicant_search_requestor) }
    it 'only instantiates one copy of the ApplicantSearchRequestor' do
      expect(requestor1).to be_instance_of(CCMS::ApplicantSearchRequestor)
      expect(requestor1).to eq requestor2
    end
  end
end
