require 'rails_helper'

RSpec.describe CCMS::UploadDocumentsService do
  let(:legal_aid_application) do
    create :legal_aid_application,
           :with_applicant,
           :with_proceeding_types,
           :with_respondent,
           :with_merits_assessment,
           :with_transaction_period,
           :with_means_report,
           :with_merits_report,
           statement_of_case: statement_of_case,
           state: :submitting_assessment
  end

  let(:statement_of_case) { create :statement_of_case, :with_attached_files }
  let(:statement_of_case_id) { statement_of_case.original_files.first.id }
  let(:means_report_id) { legal_aid_application.means_report.id }
  let(:merits_report_id) { legal_aid_application.merits_report.id }

  let!(:statement_of_case_submission_document) { create :submission_document, :id_obtained, submission: submission, document_id: statement_of_case_id }
  let!(:means_report_document) { create :submission_document, :id_obtained, submission: submission, document_type: :means_report, document_id: means_report_id }
  let!(:merits_report_document) { create :submission_document, :id_obtained, submission: submission, document_type: :merits_report, document_id: merits_report_id }

  let(:submission) do
    create :submission,
           :case_created,
           legal_aid_application: legal_aid_application,
           case_ccms_reference: Faker::Number.number(digits: 9)
  end

  let(:history) { CCMS::SubmissionHistory.find_by(submission_id: submission.id) }
  let(:document_upload_requestor) { double CCMS::DocumentUploadRequestor.new(submission.case_ccms_reference, statement_of_case_id, 'base64encodedpdf') }
  let(:document_upload_response) { ccms_data_from_file 'document_upload_response.xml' }
  let(:transaction_request_id_in_example_response) { '20190301030405123456' }
  subject { described_class.new(submission) }

  before do
    PdfConverter.call(PdfFile.find_or_create_by(original_file_id: statement_of_case_id).id)
    allow(CCMS::DocumentUploadRequestor).to receive(:new).and_return(document_upload_requestor)
    allow(document_upload_requestor).to receive(:transaction_request_id).and_return(transaction_request_id_in_example_response)
  end

  context 'operation successful' do
    before do
      allow(document_upload_requestor).to receive(:call).and_return(document_upload_response)
    end

    it 'creates a DocumentUploadRequestor object for each document to be uploaded' do
      expect(CCMS::DocumentUploadRequestor).to receive(:new).exactly(submission.submission_document.count).times
      subject.call
    end

    it 'encodes each document as base64' do
      expect(Base64).to receive(:strict_encode64).exactly(submission.submission_document.count).times
      subject.call
    end

    it 'updates the status for each document to uploaded' do
      subject.call
      submission.submission_document.each do |document|
        expect(document.status).to eq 'uploaded'
      end
    end

    it 'changes the submission state to completed' do
      expect { subject.call }.to change { submission.aasm_state }.to 'completed'
    end

    it 'writes a history record' do
      expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
      expect(history.from_state).to eq 'case_created'
      expect(history.to_state).to eq 'completed'
      expect(history.success).to be true
      expect(history.details).to be_nil
    end
  end

  context 'operation unsuccessful' do
    context 'operation fails due to an exception' do
      before do
        expect(document_upload_requestor).to receive(:call).and_raise(CCMS::CcmsError, 'failure uploading documents')
      end

      it 'changes the submission state to failed' do
        expect { subject.call }.to change { submission.aasm_state }.to 'failed'
      end

      it 'changes the document state to failed' do
        subject.call
        expect(submission.submission_document.first.status).to eq 'failed'
      end

      it 'writes a history record' do
        expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
        expect(history.from_state).to eq 'case_created'
        expect(history.to_state).to eq 'failed'
        expect(history.success).to be false
        expect(history.details).to match(/CCMS::CcmsError/)
        expect(history.details).to match(/failure uploading documents/)
      end
    end

    context 'operation fails due to an error response from ccms' do
      before do
        allow_any_instance_of(CCMS::DocumentUploadResponseParser).to receive(:success?).and_return(false)
        allow(document_upload_requestor).to receive(:call).and_return(document_upload_response)
      end

      it 'changes the submission state to failed' do
        expect { subject.call }.to change { submission.aasm_state }.to 'failed'
      end

      it 'changes the document state to failed' do
        subject.call
        expect(submission.submission_document.first.status).to eq 'failed'
      end

      it 'writes a history record' do
        expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
        expect(history.from_state).to eq 'case_created'
        expect(history.to_state).to eq 'failed'
        expect(history.success).to be false
        expect(history.details).to match('failed to upload to CCMS')
      end
    end
  end
end
