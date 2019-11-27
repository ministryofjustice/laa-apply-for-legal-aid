require 'rails_helper'

module CCMS # rubocop:disable Metrics/ModuleLength
  RSpec.describe ObtainDocumentIdService do
    let(:legal_aid_application) do
      create :legal_aid_application,
             :with_applicant,
             :with_proceeding_types,
             :with_respondent,
             :with_merits_assessment,
             :with_transaction_period,
             :with_cfe_result
    end
    let(:submission) { create :submission, :applicant_ref_obtained, legal_aid_application: legal_aid_application, case_ccms_reference: Faker::Number.number }
    let!(:statement_of_case) { create :statement_of_case, legal_aid_application: legal_aid_application }
    let(:endpoint) { 'https://sitsoa10.laadev.co.uk/soa-infra/services/default/DocumentServices/DocumentServices_ep' }
    let(:history) { SubmissionHistory.find_by(submission_id: submission.id) }
    let(:document_id_request) { ccms_data_from_file 'document_id_request.xml' }
    let(:response_body) { ccms_data_from_file 'document_id_response.xml' }

    subject { described_class.new(submission) }

    around do |example|
      VCR.turn_off!
      example.run
      VCR.turn_on!
    end

    context 'operation successful' do
      before do
        # stub a post request - any body, any headers
        stub_request(:post, endpoint).to_return(body: response_body, status: 200)

        # stub the transaction request id that we expect in the response
        allow_any_instance_of(DocumentIdRequestor).to receive(:transaction_request_id).and_return('20190301030405123456')
      end

      context 'the application has no documents' do
        it 'does not create any document objects' do
          subject.call
          expect(submission.submission_document.count).to eq 0
        end
      end

      context 'the application has documents to upload' do
        let(:statement_of_case) { create :statement_of_case, :with_original_and_pdf_files_attached, legal_aid_application: legal_aid_application }

        before do
          create :attachment, :merits_report, legal_aid_application: legal_aid_application
          create :attachment, :means_report, legal_aid_application: legal_aid_application
        end

        it 'populates the documents array with statement_of_case, means_report and merits_report' do
          subject.call
          expect(submission.submission_document.count).to eq 3
        end

        context 'when requesting document_ids' do
          it 'populates the ccms_document_id for each document' do
            subject.call
            submission.submission_document.each do |document|
              expect(document.ccms_document_id).to_not be nil
            end
          end

          it 'updates the status for each document to id_obtained' do
            subject.call
            submission.submission_document.each do |document|
              expect(document.status).to eq 'id_obtained'
            end
          end

          it 'changes the submission state to document_ids_obtained' do
            expect { subject.call }.to change { submission.aasm_state }.to 'document_ids_obtained'
          end

          it 'writes a history record' do
            expect { subject.call }.to change { SubmissionHistory.count }.by(1)
            expect(history.from_state).to eq 'applicant_ref_obtained'
            expect(history.to_state).to eq 'document_ids_obtained'
            expect(history.success).to be true
            expect(history.details).to be_nil
          end

          it 'writes the request body to the history record' do
            subject.call
            expect(history.request).to be_soap_envelope_with(
              command: 'ns2:DocumentUploadRQ',
              transaction_id: '20190301030405123456',
              matching: ['<ns4:DocumentType>ADMIN1</ns4:DocumentType>']
            )
          end

          it 'writes the response body to the history record' do
            subject.call
            expect(history.response).to eq response_body
          end
        end
      end
    end

    context 'operation unsuccessful' do
      context 'when populating documents' do
        let!(:statement_of_case) { create :statement_of_case, :with_original_and_pdf_files_attached, legal_aid_application: legal_aid_application }
        before do
          allow_any_instance_of(DocumentIdRequestor).to receive(:transaction_request_id).and_return('20190301030405123456')
          expect_any_instance_of(DocumentIdRequestor).to receive(:call).and_raise(CcmsError, 'failure populating document hash')
        end

        it 'changes the submission state to failed' do
          expect { subject.call }.to change { submission.aasm_state }.to 'failed'
        end

        it 'writes a history record' do
          expect { subject.call }.to change { SubmissionHistory.count }.by(1)
          expect(history.from_state).to eq 'applicant_ref_obtained' # this is failing gets case_submitted
          expect(history.to_state).to eq 'failed'
          expect(history.success).to be false
          expect(history.details).to match(/CCMS::CcmsError/)
          expect(history.details).to match(/failure populating document hash/)
          expect(history.request).not_to be_nil
          expect(history.request).to be_soap_envelope_with(
            command: 'ns2:DocumentUploadRQ',
            transaction_id: '20190301030405123456',
            matching: [
              '<ns4:DocumentType>ADMIN1</ns4:DocumentType>'
            ]
          )
          expect(history.response).to be_nil
        end
      end

      context 'when requesting document_ids' do
        before do
          expect_any_instance_of(DocumentIdRequestor).to receive(:call).and_raise(CcmsError, 'failure populating document hash')
        end

        let(:statement_of_case) { create :statement_of_case, :with_original_and_pdf_files_attached, legal_aid_application: legal_aid_application }

        it 'changes the submission state to failed' do
          expect { subject.call }.to change { submission.aasm_state }.to 'failed'
        end

        it 'changes the document state to failed' do
          subject.call
          expect(submission.submission_document.first.status).to eq 'failed'
        end

        it 'writes a history record' do
          expect { subject.call }.to change { SubmissionHistory.count }.by(1)
          expect(history.from_state).to eq 'applicant_ref_obtained'
          expect(history.to_state).to eq 'failed'
          expect(history.success).to be false
          expect(history.details).to match(/CCMS::CcmsError/)
          expect(history.details).to match(/failure populating document hash/)
          expect(history.request).to be_soap_envelope_with(
            command: 'ns2:DocumentUploadRQ',
            matching: ['<ns2:CaseReferenceNumber>\d{10}</ns2:CaseReferenceNumber>']
          )
          expect(history.response).to be_nil
        end
      end
    end
  end
end
