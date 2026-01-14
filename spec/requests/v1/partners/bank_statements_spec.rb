require "rails_helper"

# This tests the javascript enabled path for uploading bank statements
# since this endpoint is called by dropzone.
#
# NOTE: empty files, over-large files, unacceptable format files
# are handled by the javascript in dropzone.js and never reach this
# endpoint so are not tested here.
#
RSpec.describe "POST /v1/partners/bank_statements" do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:id) { legal_aid_application.id }
  let(:file) { uploaded_file("spec/fixtures/files/documents/hello_world.pdf", "application/pdf") }
  let(:params) { { legal_aid_application_id: id, file: } }

  describe "POST /v1/partners/bank_statements" do
    subject(:request) { post v1_partners_bank_statements_path, params: }

    context "when the application exists" do
      it "returns http success" do
        request
        expect(response).to have_http_status(:success)
      end

      it "adds the attachment to the legal aid application" do
        expect { request }.to change { legal_aid_application.reload.attachments.count }.by 1
      end

      it "enqueues job to convert uploaded attachment document to pdf" do
        expect { request }.to change(PDFConverterWorker.jobs, :size).by(1)
        expect(PDFConverterWorker.jobs[0]["args"]).to include(legal_aid_application.reload.attachments.last.id)
      end

      it "attachment has expected attributes" do
        request
        expect(legal_aid_application.reload.attachments.last)
          .to have_attributes(document: be_a(ActiveStorage::Attached::One),
                              attachment_type: "part_bank_state_evidence",
                              original_filename: "hello_world.pdf",
                              attachment_name: "part_bank_state_evidence")
      end

      context "with background job processing" do
        around do |example|
          Sidekiq::Testing.inline!
          example.run
          Sidekiq::Testing.fake!
        end

        it "adds 2 attachments" do
          expect { request }.to change(legal_aid_application.attachments, :count).by(2)
        end

        it "adds original and converted attachments types" do
          request
          expect(legal_aid_application.reload.attachments.pluck(:attachment_type)).to match_array(%w[part_bank_state_evidence part_bank_state_evidence_pdf])
        end

        it "associates pdf converted attachment to original attachment" do
          request
          original_attachment = legal_aid_application.attachments.find_by(attachment_type: "part_bank_state_evidence")
          expect(original_attachment.pdf_attachment_id).not_to be_nil
        end
      end

      context "when the application has no bank statements" do
        let(:legal_aid_application) { create(:legal_aid_application, attachments: []) }

        it "does not increment the attachment name" do
          request
          expect(legal_aid_application.attachments.count).to be 1
          expect(legal_aid_application.reload.attachments.last.attachment_name).to match("part_bank_state_evidence")
        end
      end

      context "when the application has one bank statement attachment already" do
        let(:part_bank_state_evidence) { create(:attachment, :partner_bank_statement, attachment_name: "part_bank_state_evidence") }
        let!(:legal_aid_application) { create(:legal_aid_application, attachments: [part_bank_state_evidence]) }

        it "increments the attachment name" do
          request
          expect(legal_aid_application.attachments.count).to be 2
          expect(legal_aid_application.attachments.order(:attachment_name).last.attachment_name).to eql("part_bank_state_evidence_1")
        end
      end

      context "when the application has multiple attachments for bank statement already" do
        let(:bs1) { create(:attachment, :partner_bank_statement, attachment_name: "part_bank_state_evidence") }
        let(:bs2) { create(:attachment, :partner_bank_statement, attachment_name: "part_bank_state_evidence_1") }
        let!(:legal_aid_application) { create(:legal_aid_application, attachments: [bs1, bs2]) }

        it "increments the attachment name" do
          request
          expect(legal_aid_application.attachments.count).to be 3
          expect(legal_aid_application.attachments.order(:attachment_name).last.attachment_name).to eql("part_bank_state_evidence_2")
        end
      end

      context "when the file is a csv" do
        let(:file) { uploaded_file("spec/fixtures/files/sample_csv.csv", "text/csv") }

        it "saves the object" do
          request
          expect(legal_aid_application.attachments.count).to be 1
        end
      end

      context "when the file contains malware", :clamav do
        let(:file) { uploaded_file("spec/fixtures/files/malware.doc", "application/pdf") }

        it "does not save the object and raises a 400 error with text" do
          request
          expect(legal_aid_application.attachments.count).to be 0
          expect(response).to have_http_status(:bad_request)
          expect(response.body).to include("malware.doc contains a virus")
        end
      end

      context "when the virus scanner is down" do
        before do
          malware_scan_result = instance_double(MalwareScanResult, virus_found?: false, scanner_working: false)
          allow(MalwareScanner).to receive(:call).and_return(malware_scan_result)
        end

        it "does not save the object and raises a 500 error with text" do
          request
          expect(legal_aid_application.attachments.count).to match(0)
          expect(response).to have_http_status(:bad_request)
          expect(response.body).to include("There was a problem uploading your file - try again")
        end
      end
    end

    context "when the application does not exist" do
      let(:id) { SecureRandom.hex }

      it "returns http not found" do
        request
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
