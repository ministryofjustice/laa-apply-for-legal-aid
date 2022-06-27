require "rails_helper"

RSpec.describe "POST /v1/bank_statements", type: :request do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:id) { legal_aid_application.id }
  let(:file) { uploaded_file("spec/fixtures/files/documents/hello_world.pdf", "application/pdf") }
  let(:params) { { legal_aid_application_id: id, file: } }

  describe "POST /v1/bank_statements" do
    subject(:request) { post v1_bank_statements_path, params: }

    context "when the application exists" do
      it "returns http success" do
        request
        expect(response).to have_http_status(:success)
      end

      it "adds the bank statement to the legal aid application" do
        expect { request }.to change { legal_aid_application.reload.attachments.length }.by 1
      end

      context "when the application has no bank statements" do
        let(:legal_aid_application) { create :legal_aid_application, attachments: [] }

        it "does not increment the attachment name" do
          request
          expect(legal_aid_application.reload.attachments.length).to match(1)
          expect(legal_aid_application.reload.attachments.last.attachment_name).to match("bank_statement_evidence")
        end
      end

      context "when the application has one bank statment attachment already" do
        let(:bank_statement_evidence) { create(:attachment, :bank_statement, attachment_name: "bank_statement_evidence") }
        let!(:legal_aid_application) { create(:legal_aid_application, attachments: [bank_statement_evidence]) }

        it "increments the attachment name" do
          request
          expect(legal_aid_application.reload.attachments.length).to be 2
          expect(legal_aid_application.reload.attachments.order(:attachment_name).last.attachment_name).to eql("bank_statement_evidence_1")
        end
      end

      context "when the application has multiple attachments for statement of case already" do
        let(:bs1) { create(:attachment, :bank_statement, attachment_name: "bank_statement_evidence") }
        let(:bs2) { create(:attachment, :bank_statement, attachment_name: "bank_statement_evidence_1") }
        let!(:legal_aid_application) { create(:legal_aid_application, attachments: [bs1, bs2]) }

        it "increments the attachment name" do
          request
          expect(legal_aid_application.reload.attachments.length).to be 3
          expect(legal_aid_application.reload.attachments.order(:attachment_name).last.attachment_name).to eql("bank_statement_evidence_2")
        end
      end

      context "when the file contains malware" do
        let(:file) { uploaded_file("spec/fixtures/files/malware.doc", "application/pdf") }

        it "does not save the object and raises a 400 error with text" do
          request
          expect(legal_aid_application.reload.attachments.length).to be 0
          expect(response.status).to eq 400
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
          expect(legal_aid_application.reload.attachments.length).to match(0)
          expect(response.status).to eq 400
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
