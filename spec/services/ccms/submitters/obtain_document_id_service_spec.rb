require "rails_helper"

module CCMS
  module Submitters
    RSpec.describe ObtainDocumentIdService, :ccms do
      subject(:instance) { described_class.new(submission) }

      let(:legal_aid_application) do
        create(:legal_aid_application,
               :with_applicant,
               :with_proceedings,
               :with_opponent,
               :with_transaction_period,
               :with_cfe_v3_result,
               :with_merits_submitted_at)
      end
      let(:chances_of_success) { create(:chances_of_success, application_proceeding_type: legal_aid_application.lead_application_proceeding_type) }
      let(:submission) { create(:submission, :applicant_ref_obtained, legal_aid_application:, case_ccms_reference: Faker::Number.number) }
      let(:endpoint) { "https://ccms-soa-managed.laa-test.modernisation-platform.service.justice.gov.uk/soa-infra/services/default/DocumentServices/DocumentServices_ep" }
      let(:history) { SubmissionHistory.where(submission_id: submission.id).last }
      let(:document_id_request) { ccms_data_from_file "document_id_request.xml" }
      let(:response_body) { ccms_data_from_file "document_id_response.xml" }

      before { create(:statement_of_case, legal_aid_application:) }

      around do |example|
        VCR.turn_off!
        DocumentCategory.populate
        example.run
        VCR.turn_on!
      end

      context "when the operation is successful" do
        before do
          # stub a post request - any body, any headers
          stub_request(:post, endpoint).to_return(body: response_body, status: 200)

          # stub the transaction request id that we expect in the response
          allow_any_instance_of(CCMS::Requestors::DocumentIdRequestor).to receive(:transaction_request_id).and_return("20190301030405123456")
        end

        context "and the application has no documents" do
          it "does not create any document objects" do
            instance.call
            expect(submission.submission_documents.count).to eq 0
          end
        end

        context "and the application has documents to upload" do
          before do
            create(:attachment, :merits_report, legal_aid_application:)
            create(:attachment, :means_report, legal_aid_application:)
            create(:attachment, :bank_transaction_report, legal_aid_application:)
            create(:statement_of_case, :with_original_and_pdf_files_attached, legal_aid_application:)
            create(:uploaded_evidence_collection, :with_original_and_pdf_files_attached, legal_aid_application:)
            submission.submission_documents << failed_submission_document
          end

          let(:all_attachment_types) do
            %w[
              merits_report
              means_report
              bank_transaction_report
              statement_of_case_pdf
              statement_of_case
              gateway_evidence_pdf
              gateway_evidence
            ]
          end

          let(:submittable_document_types) do
            %w[
              merits_report
              means_report
              bank_transaction_report
              statement_of_case_pdf
              gateway_evidence_pdf
            ]
          end

          let(:failed_submission_document) { create(:submission_document, :failed, attachment_id: legal_aid_application.attachments.find_by(attachment_name: "statement_of_case").id) }

          it "only populates the documents array with submittable documents" do
            expect(legal_aid_application.attachments.map(&:attachment_type)).to match_array all_attachment_types
            instance.call
            expect(submission.submission_documents.map(&:document_type)).to match_array submittable_document_types
          end

          it "populates document array with gateway_evidence" do
            instance.call
            gateway_evidence_submission = submission.submission_documents.select { |a| a.document_type == "gateway_evidence_pdf" }
            expect(gateway_evidence_submission.count).to eq 1
          end

          it "deletes any existing submission documents" do
            expect { instance.call }.to change { SubmissionDocument.exists?(failed_submission_document.id) }.to false
          end

          context "when requesting document_ids" do
            it "populates the ccms_document_id for each document" do
              instance.call
              submission.submission_documents.each do |document|
                expect(document.ccms_document_id).not_to be_nil
              end
            end

            it "updates the status for each document to id_obtained" do
              instance.call
              submission.submission_documents.each do |document|
                expect(document.status).to eq "id_obtained"
              end
            end

            it "changes the submission state to document_ids_obtained" do
              expect { instance.call }.to change(submission, :aasm_state).to "document_ids_obtained"
            end

            it "writes a history record for each document" do
              expect { instance.call }.to change(SubmissionHistory, :count).by(5)
            end

            it "updates the history records" do
              instance.call
              expect(history.from_state).to eq "applicant_ref_obtained"
              expect(history.to_state).to eq "document_ids_obtained"
              expect(history.success).to be true
              expect(history.details).to be_nil
            end

            it "writes the request body to the history record" do
              instance.call
              expect(history.request).to be_soap_envelope_with(
                command: "casebim:DocumentUploadRQ",
                transaction_id: "20190301030405123456",
                matching: ["<casebio:Channel>E</casebio:Channel>"],
              )
            end

            it "creates two documents as REPORT, one as STATE, one as BSTMT, and one as EX_RPT and no ADMIN1 files any more" do
              instance.call
              admin1_documents = SubmissionHistory.where(submission_id: submission.id).map(&:request).map { |x| x.scan("ADMIN1") }.flatten.count
              report_documents = SubmissionHistory.where(submission_id: submission.id).map(&:request).map { |x| x.scan("REPORT") }.flatten.count
              state_documents = SubmissionHistory.where(submission_id: submission.id).map(&:request).map { |x| x.scan("STATE") }.flatten.count
              bstmt_documents = SubmissionHistory.where(submission_id: submission.id).map(&:request).map { |x| x.scan("BSTMT") }.flatten.count
              expert_documents = SubmissionHistory.where(submission_id: submission.id).map(&:request).map { |x| x.scan("EX_RPT") }.flatten.count
              expect(state_documents).to eq 1
              expect(bstmt_documents).to eq 1
              expect(expert_documents).to eq 1
              expect(report_documents).to eq 2
              expect(admin1_documents).to eq 0
            end

            it "writes the response body to the history record" do
              instance.call
              expect(history.response).to eq response_body
            end
          end
        end
      end

      context "when the operation is unsuccessful" do
        let(:history) { SubmissionHistory.where(submission_id: submission.id, request: nil, response: nil).last }
        # There should only be one record in this state, so if it fails it's a legitimate error,
        # previously a race condition would occur where both records where created to
        # the microsecond :(

        context "when populating documents" do
          let(:error) { [CCMS::CCMSError, Faraday::Error, Faraday::SoapError, StandardError] }
          let(:fake_error) { error.sample }

          before do
            allow_any_instance_of(CCMS::Requestors::DocumentIdRequestor).to receive(:transaction_request_id).and_return("20190301030405123456")
            allow_any_instance_of(CCMS::Requestors::DocumentIdRequestor).to receive(:call).and_raise(fake_error, "Failed to obtain document ids for")
            create(:statement_of_case, :with_original_and_pdf_files_attached, legal_aid_application:)
          end

          it "does not change the state" do
            expect { instance.call }.to raise_error(fake_error, "Failed to obtain document ids for")
            expect(submission.aasm_state).to eq "applicant_ref_obtained"
          end

          it "writes a history record" do
            expect { instance.call }.to raise_error(fake_error, "Failed to obtain document ids for")
            expect(SubmissionHistory.count).to eq 2
            expect(history.from_state).to eq "applicant_ref_obtained" # this is failing gets case_submitted
            expect(history.to_state).to eq "failed"
            expect(history.success).to be false
            expect(history.details).to match(/#{error}/)
            expect(history.details).to match(/Failed to obtain document ids for/)
            expect(history.request).to be_nil
            expect(history.response).to be_nil
          end

          it "does not create duplicate submission documents when called multiple times" do
            expect { instance.call }.to raise_error(fake_error, "Failed to obtain document ids for")
            expect(submission.reload.submission_documents.count).to eq 1
            expect { instance.call }.to raise_error(fake_error, "Failed to obtain document ids for")
            expect(submission.reload.submission_documents.count).to eq 1
          end
        end

        context "when requesting document_ids" do
          before do
            allow_any_instance_of(CCMS::Requestors::DocumentIdRequestor).to receive(:call).and_raise(CCMSError, "failure populating document hash")
            create(:statement_of_case, :with_original_and_pdf_files_attached, legal_aid_application:)
          end

          it "does not change the state" do
            expect { instance.call }.to raise_error(CCMSError, "failure populating document hash")
            expect(submission.aasm_state).to eq "applicant_ref_obtained"
          end

          it "changes the document state to failed" do
            expect { instance.call }.to raise_error(CCMSError, "failure populating document hash")
            expect(submission.submission_documents.first.status).to eq "failed"
          end

          it "writes a history record" do
            expect { instance.call }.to raise_error(CCMSError, "failure populating document hash")
            expect(SubmissionHistory.count).to eq 2
            expect(history.from_state).to eq "applicant_ref_obtained"
            expect(history.to_state).to eq "failed"
            expect(history.success).to be false
            expect(history.details).to match(/CCMS::CCMSError/)
            expect(history.details).to match(/failure populating document hash/)
            expect(history.request).to be_nil
            expect(history.response).to be_nil
          end
        end
      end
    end
  end
end
