require 'rails_helper'

RSpec.describe CCMS::ObtainDocumentIdService do
  let(:legal_aid_application) { create :legal_aid_application, statement_of_case: statement_of_case }
  let(:submission) { create :submission, :case_created, legal_aid_application: legal_aid_application, case_ccms_reference: Faker::Number.number }
  let(:statement_of_case) { create :statement_of_case }
  let(:history) { CCMS::SubmissionHistory.find_by(submission_id: submission.id) }
  let(:document_id_requestor) { double CCMS::DocumentIdRequestor.new(submission.case_ccms_reference) }
  subject { described_class.new(submission) }

  context 'operation successful' do
    context 'the application has no documents' do
      it 'creates an empty documents hash' do
        subject.call
        expect(submission.documents&.size).to eq 0
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

    context 'the application has documents to upload' do
      let(:statement_of_case) { create :statement_of_case, :with_attached_files }
      let(:document_id_response) { ccms_data_from_file 'document_id_response.xml' }
      let(:transaction_request_id_in_example_response) { '20190301030405123456' }
      let(:ccms_document_id_in_example_response) { '4420073' }

      before do
        allow(subject).to receive(:document_id_requestor).and_return(document_id_requestor)
        expect(document_id_requestor).to receive(:transaction_request_id).and_return(transaction_request_id_in_example_response)
        expect(document_id_requestor).to receive(:call).and_return(document_id_response)
      end

      it 'populates the documents hash with all documents for the application' do
        subject.call
        expect(submission.documents&.size).to eq statement_of_case.original_files.count
      end

      context 'when requesting document_ids' do
        it 'updates the ccms_document_id for each document' do
          subject.call
          submission.documents.each do |key, _value|
            expect(PdfFile.find_by(original_file_id: key).ccms_document_id).to eq ccms_document_id_in_example_response
          end
        end

        it 'updates the status for each document to id_obtained' do
          subject.call
          submission.documents.each do |_key, value|
            expect(value).to eq :id_obtained
          end
        end

        it 'changes the submission state to document_ids_obtained' do
          expect { subject.call }.to change { submission.aasm_state }.to 'document_ids_obtained'
        end
      end
    end
  end

  context 'operation unsuccessful' do
    context 'when populating documents' do
      before do
        expect(subject).to receive(:populate_documents).and_raise(CCMS::CcmsError, 'failure populating document hash')
      end

      it 'changes the submission state to failed' do
        expect { subject.call }.to change { submission.aasm_state }.to 'failed'
      end

      it 'writes a history record' do
        expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
        expect(history.from_state).to eq 'case_created'
        expect(history.to_state).to eq 'failed'
        expect(history.success).to be false
        expect(history.details).to match(/CCMS::CcmsError/)
        expect(history.details).to match(/failure populating document hash/)
      end
    end

    context 'when requesting document_ids' do
      let(:statement_of_case) { create :statement_of_case, :with_attached_files }

      before do
        allow(subject).to receive(:document_id_requestor).and_return(document_id_requestor)
        expect(document_id_requestor).to receive(:transaction_request_id).and_return(Faker::Number.number(digits: 8))
        expect(document_id_requestor).to receive(:call).and_raise(CCMS::CcmsError, 'failure requesting document ids')
      end

      it 'changes the submission state to failed' do
        expect { subject.call }.to change { submission.aasm_state }.to 'failed'
      end

      it 'changes the document state to failed' do
        expect { subject.call }.to change { submission.documents[statement_of_case.original_files.first.id] }.to eq :failed
      end

      it 'writes a history record' do
        expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
        expect(history.from_state).to eq 'case_created'
        expect(history.to_state).to eq 'failed'
        expect(history.success).to be false
        expect(history.details).to match(/CCMS::CcmsError/)
        expect(history.details).to match(/failure requesting document ids/)
      end
    end
  end

  # private method tested here because it is mocked out above
  #
  describe '#document_id_requestor' do
    let(:service) { CCMS::ObtainDocumentIdService.new(submission) }
    let(:requestor1) { service.__send__(:document_id_requestor) }
    let(:requestor2) { service.__send__(:document_id_requestor) }
    it 'only instantiates one copy of the DocumentIdRequestor' do
      expect(requestor1).to be_instance_of(CCMS::DocumentIdRequestor)
      expect(requestor1).to eq requestor2
    end
  end
end
