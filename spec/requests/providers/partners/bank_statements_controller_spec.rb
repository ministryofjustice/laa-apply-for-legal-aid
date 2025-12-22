require "rails_helper"

# This excerises the non-javascript enabled path.
# 1. see v1/bank_statements_controller for requests that would come from dropzone/ajax
# 2. see cucumber features for full JS enabled integration tests.

RSpec.describe Providers::Partners::BankStatementsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_partner, :provider_confirming_applicant_eligibility, :with_cfe_v5_result, attachments:) }
  let(:id) { legal_aid_application.id }
  let(:attachments) { [] }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/partners/bank_statements" do
    subject(:request) { get providers_legal_aid_application_partners_bank_statements_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before { login_as provider }

      it "returns http success" do
        request
        expect(response).to have_http_status(:ok)
      end

      it "sets the transaction period" do
        expect {
          request
        }.to change { legal_aid_application.reload.transaction_period_start_on }.from(nil).to(kind_of(Date))
        .and change { legal_aid_application.reload.transaction_period_finish_on }.from(nil).to(kind_of(Date))
      end

      context "when no bank statements exists for the application" do
        it "renders uploaded files" do
          request
          expect(response).to render_template("shared/_uploaded_files")
        end

        it "displays fallback text" do
          request
          expect(response.body).to include("Files uploaded will appear here")
        end
      end

      context "when a bank statement already exists for the application" do
        let(:attachments) { [attachment] }
        let(:attachment) { create(:attachment, :partner_bank_statement) }

        # NOTE: factory implicitly attaches the hello_world.pdf
        it "displays the name of the uploaded file on the page" do
          request
          expect(response.body).to include("hello_world.pdf")
        end
      end
    end
  end

  describe "GET /providers/applications/:legal_aid_application_id/partners/bank_statements/list" do
    subject(:request) { get list_providers_legal_aid_application_partners_bank_statements_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        request
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it { expect(response).to render_template("shared/_uploaded_files") }
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/partners/bank_statements" do
    subject(:request) { patch providers_legal_aid_application_partners_bank_statements_path(legal_aid_application), params: }

    let(:upload_button) { { upload_button: "Upload" } }
    let(:button_clicked) { {} }

    let(:params) do
      {
        legal_aid_application_id: legal_aid_application.id,
        original_file: file,
      }.merge(button_clicked)
    end

    before { login_as provider }

    context "when upload button clicked" do
      let(:button_clicked) { upload_button }

      context "when the file is a csv" do
        let(:file) { uploaded_file("spec/fixtures/files/sample_csv.csv", "text/csv") }

        it "saves the object" do
          request
          expect(legal_aid_application.reload.attachments.length).to match(1)
        end

        it "stores the original filename" do
          request
          expect(legal_aid_application.reload.attachments.last.original_filename).to eq "sample_csv.csv"
        end
      end

      context "with acceptable bank statement" do
        let(:file) { uploaded_file("spec/fixtures/files/acceptable.pdf", "application/pdf") }

        it "adds an attachment object" do
          expect { request }.to change(legal_aid_application.attachments, :count).by(1)
        end

        it "enqueues job to convert uploaded attachment document to pdf" do
          expect { request }.to change(PDFConverterWorker.jobs, :size).by(1)
          expect(PDFConverterWorker.jobs[0]["args"]).to include(legal_aid_application.reload.attachments.last.id)
        end

        it "stores the original filename" do
          request
          expect(legal_aid_application.reload.attachments.last.original_filename).to eq "acceptable.pdf"
        end

        it "returns http success" do
          request
          expect(response).to have_http_status(:ok)
        end

        it "sets attachment_name to model name" do
          request
          expect(legal_aid_application.reload.attachments.last.attachment_name).to eq("part_bank_state_evidence")
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

        context "when the application has one bank statement attachment already" do
          let(:part_bank_state_evidence) { create(:attachment, :partner_bank_statement, attachment_name: "part_bank_state_evidence") }
          let!(:legal_aid_application) { create(:legal_aid_application, attachments: [part_bank_state_evidence]) }

          it "increments the attachment name" do
            request
            expect(legal_aid_application.reload.attachments.pluck(:attachment_name)).to match_array(%w[part_bank_state_evidence part_bank_state_evidence_1])
          end
        end

        context "when the application has multiple attachments for statement of case already" do
          let(:bs1) { create(:attachment, :partner_bank_statement, attachment_name: "part_bank_state_evidence") }
          let(:bs2) { create(:attachment, :partner_bank_statement, attachment_name: "part_bank_state_evidence_1") }
          let!(:legal_aid_application) { create(:legal_aid_application, attachments: [bs1, bs2]) }

          it "increments the attachment name" do
            request
            expect(legal_aid_application.reload.attachments.pluck(:attachment_name)).to match_array(%w[part_bank_state_evidence part_bank_state_evidence_1 part_bank_state_evidence_2])
          end
        end
      end

      context "when file to big" do
        let(:file) { uploaded_file("spec/fixtures/files/too_large.pdf", "application/pdf") }

        it "does not add attachment object" do
          expect { request }.not_to change(legal_aid_application.attachments, :count)
        end

        it "does not enqueue job to convert upload to pdf" do
          expect { request }.not_to change(PDFConverterWorker.jobs, :size)
        end

        it "returns http success" do
          request
          expect(response).to have_http_status(:ok)
        end

        it "displays error indicating file too large" do
          request
          expect(response.body).to have_css("h2", text: "There is a problem").and have_link("too_large.pdf must be smaller than 7MB")
        end
      end

      context "when file has no content" do
        let(:file) { uploaded_file("spec/fixtures/files/empty_file.pdf", "application/pdf") }

        it "does not add attachment object" do
          expect { request }.not_to change(legal_aid_application.attachments, :count)
        end

        it "does not enqueue job to convert upload to pdf" do
          expect { request }.not_to change(PDFConverterWorker.jobs, :size)
        end

        it "returns http success" do
          request
          expect(response).to have_http_status(:ok)
        end

        it "displays error indicating file is empty" do
          request
          expect(response.body).to have_css("h2", text: "There is a problem").and have_link("empty_file.pdf has no content")
        end
      end

      context "when file is of wrong content type" do
        let(:file) { uploaded_file("spec/fixtures/files/zip.zip", "application/zip") }

        it "does not add attachment object" do
          expect { request }.not_to change(legal_aid_application.attachments, :count)
        end

        it "does not enqueue job to convert upload to pdf" do
          expect { request }.not_to change(PDFConverterWorker.jobs, :size)
        end

        it "returns http success" do
          request
          expect(response).to have_http_status(:ok)
        end

        it "displays error indicating file is of the wrong content type" do
          request
          expect(response.body).to have_css("h2", text: "There is a problem").and have_link("zip.zip must be a DOC, DOCX, RTF, ODT, JPG, BMP, PNG, TIF, CSV or PDF")
        end
      end

      context "when file contains a virus", :clamav do
        let(:file) { uploaded_file("spec/fixtures/files/malware.doc") }

        it "does not add attachment object" do
          expect { request }.not_to change(legal_aid_application.attachments, :count)
        end

        it "does not enqueue job to convert upload to pdf" do
          expect { request }.not_to change(PDFConverterWorker.jobs, :size)
        end

        it "returns http success" do
          request
          expect(response).to have_http_status(:ok)
        end

        it "displays error indicating file contains a virus" do
          request
          expect(response.body).to have_css("h2", text: "There is a problem").and have_link("malware.doc contains a virus")
        end
      end

      context "when virus scanner is down" do
        let(:file) { uploaded_file("spec/fixtures/files/acceptable.pdf", "application/pdf") }

        before do
          malware_scan_result = instance_double(MalwareScanResult, virus_found?: false, scanner_working: false)
          allow(MalwareScanner).to receive(:call).and_return(malware_scan_result)
        end

        it "returns error message" do
          request
          expect(response.body).to include("There was a problem uploading your file - try again")
        end
      end
    end

    context "when save and continue button clicked" do
      subject(:request) do
        patch(providers_legal_aid_application_partners_bank_statements_path(legal_aid_application),
              params: { continue_button: "Save and continue" })
      end

      context "with files already attached" do
        before do
          patch(providers_legal_aid_application_partners_bank_statements_path(legal_aid_application),
                params: { upload_button: "Upload",
                          original_file: uploaded_file("spec/fixtures/files/acceptable.pdf", "application/pdf") })
          allow(HMRC::StatusAnalyzer).to receive(:call).and_return :partner_multiple_employments
        end

        it "does not add attachment object" do
          expect { request }.not_to change(legal_aid_application.attachments, :count)
        end

        context "when HMRC response status is known" do
          it "redirects to the next page" do
            request
            expect(response).to have_http_status(:redirect)
          end
        end

        context "when HMRC response status is unexpected" do
          before do
            allow(HMRC::StatusAnalyzer).to receive(:call).and_return :foobar
          end

          it "raises error" do
            expect { request }.to raise_error RuntimeError, "Unexpected hmrc status :foobar"
          end
        end
      end

      context "with no files attached" do
        it "does not add attachment object" do
          expect { request }.not_to change(legal_aid_application.attachments, :count)
        end

        it "renders :show, again" do
          request
          expect(response).to render_template(:show)
        end

        it "displays error indicating a file is needed" do
          request
          expect(response.body).to have_css("h2", text: "There is a problem").and have_link("Upload the partner's bank statements")
        end
      end
    end

    context "when save and come back later is clicked" do
      subject(:request) do
        patch(providers_legal_aid_application_partners_bank_statements_path(legal_aid_application),
              params: { draft_button: "" })
      end

      context "with files already attached" do
        before do
          patch(providers_legal_aid_application_partners_bank_statements_path(legal_aid_application),
                params: { upload_button: "Upload",
                          original_file: uploaded_file("spec/fixtures/files/acceptable.pdf", "application/pdf") })
        end

        it "does not add attachment object" do
          expect { request }.not_to change(legal_aid_application.attachments, :count)
        end

        it "redirects to provider's application list" do
          request
          expect(response).to redirect_to in_progress_providers_legal_aid_applications_path
        end
      end

      context "with no files attached" do
        it "does not add attachment object" do
          expect { request }.not_to change(legal_aid_application.attachments, :count)
        end

        it "redirects to provider's application list" do
          request
          expect(response).to redirect_to in_progress_providers_legal_aid_applications_path
        end
      end
    end
  end

  describe "DELETE /providers/applications/:legal_aid_application_id/partners/bank_statements" do
    subject(:request) { delete providers_legal_aid_application_partners_bank_statements_path(legal_aid_application), params: }

    before { login_as provider }

    context "with existing file" do
      let(:params) { { attachment_id: legal_aid_application.attachments.part_bank_state_evidence.first.id } }

      before do
        patch(providers_legal_aid_application_partners_bank_statements_path(legal_aid_application),
              params: { upload_button: "Upload",
                        original_file: uploaded_file("spec/fixtures/files/acceptable.pdf", "application/pdf") })
      end

      it "deletes the attachment object" do
        expect { request }.to change(legal_aid_application.attachments, :count).by(-1)
      end

      it "returns http success" do
        request
        expect(response).to have_http_status(:ok)
      end

      it "renders :show" do
        request
        expect(response).to render_template(:show)
      end

      it "renders govuk notification banner indicating successful deletion" do
        request
        expect(response.body).to have_css("div.govuk-notification-banner", text: "acceptable.pdf has been successfully deleted")
      end

      context "with background job processing" do
        around do |example|
          Sidekiq::Testing.inline!
          example.run
          Sidekiq::Testing.fake!
        end

        it "deletes original attachment and converted pdf attachment" do
          expect { request }.to change(legal_aid_application.attachments, :count).by(-2)
        end
      end
    end

    context "with non-existent file" do
      let(:params) { { attachment_id: :unknown } }

      it "does not delete any attachment objects" do
        expect { request }.not_to change(legal_aid_application.attachments, :count)
      end

      it "returns http success" do
        request
        expect(response).to have_http_status(:ok)
      end

      it "renders :show" do
        request
        expect(response).to render_template(:show)
      end
    end
  end
end
