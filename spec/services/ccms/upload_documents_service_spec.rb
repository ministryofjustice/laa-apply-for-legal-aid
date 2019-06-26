require 'rails_helper'

RSpec.describe CCMS::UploadDocumentsService do
  let(:legal_aid_application) { create :legal_aid_application, statement_of_case: statement_of_case }
  let(:statement_of_case) { create :statement_of_case, :with_attached_files }
  let(:document_id) { statement_of_case.original_files.first.id }
  let(:submission) do
    create :submission,
           :document_ids_obtained,
           legal_aid_application: legal_aid_application,
           case_ccms_reference: Faker::Number.number(9),
           documents: { document_id => :id_obtained }
  end
  let(:history) { CCMS::SubmissionHistory.find_by(submission_id: submission.id) }
  let(:document_upload_requestor) { double CCMS::DocumentUploadRequestor.new(submission.case_ccms_reference, document_id, 'base64encodedpdf') }
  let(:document_upload_response) { ccms_data_from_file 'document_upload_response.xml' }
  let(:transaction_request_id_in_example_response) { '20190301030405123456' }
  subject { described_class.new(submission) }

  before do
    PdfConverter.call(PdfFile.find_or_create_by(original_file_id: document_id).id)
    allow(CCMS::DocumentUploadRequestor).to receive(:new).and_return(document_upload_requestor)
    expect(document_upload_requestor).to receive(:transaction_request_id).and_return(transaction_request_id_in_example_response)
  end

  context 'operation successful' do
    before do
      expect(document_upload_requestor).to receive(:call).and_return(document_upload_response)
    end

    it 'creates a DocumentUploadRequestor object for each document to be uploaded' do
      expect(CCMS::DocumentUploadRequestor).to receive(:new).exactly(submission.documents.count).times
      subject.call
    end

    it 'encodes each document as base64' do
      expect(Base64).to receive(:strict_encode64).exactly(submission.documents.count).times
      subject.call
    end

    it 'updates the status for each document to uploaded' do
      subject.call
      submission.documents.each do |_key, value|
        expect(value).to eq :uploaded
      end
    end

    it 'changes the submission state to completed' do
      expect { subject.call }.to change { submission.aasm_state }.to 'completed'
    end

    it 'writes a history record' do
      expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
      expect(history.from_state).to eq 'document_ids_obtained'
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
        expect { subject.call }.to change { submission.documents[statement_of_case.original_files.first.id] }.to eq :failed
      end

      it 'writes a history record' do
        expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
        expect(history.from_state).to eq 'document_ids_obtained'
        expect(history.to_state).to eq 'failed'
        expect(history.success).to be false
        expect(history.details).to match(/CCMS::CcmsError/)
        expect(history.details).to match(/failure uploading documents/)
      end
    end

    context 'operation fails due to an error response from ccms' do
      before do
        allow_any_instance_of(CCMS::DocumentUploadResponseParser).to receive(:success?).and_return(false)
        expect(document_upload_requestor).to receive(:call).and_return(document_upload_response)
      end

      it 'changes the submission state to failed' do
        expect { subject.call }.to change { submission.aasm_state }.to 'failed'
      end

      it 'changes the document state to failed' do
        expect { subject.call }.to change { submission.documents[statement_of_case.original_files.first.id] }.to eq :failed
      end

      it 'writes a history record' do
        expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
        expect(history.from_state).to eq 'document_ids_obtained'
        expect(history.to_state).to eq 'failed'
        expect(history.success).to be false
        expect(history.details).to match('failed to upload to CCMS')
      end
    end
  end
end
