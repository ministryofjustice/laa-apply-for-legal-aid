require "rails_helper"
# require "sidekiq/testing"

RSpec.describe "Providers::BankStatementsController", type: :request do
  let(:legal_aid_application) { create(:legal_aid_application, attachments:) }
  let(:id) { legal_aid_application.id }
  let(:attachments) { [] }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/bank_statements" do
    subject(:request) { get providers_legal_aid_application_bank_statements_path(legal_aid_application) }

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

      context "when no bank statements exists for the application" do
        let(:attachments) { [] }

        it { expect(response).to render_template("providers/bank_statements/_uploaded_files") }

        it "displays fallback text" do
          expect(response.body).to include("Files uploaded will appear here")
        end
      end

      context "when bank statements already exists for the application" do
        let(:attachments) { [bank_statement_evidence] }
        let(:bank_statement_evidence) { create(:attachment, :bank_statement, attachment_name: "bank_statement_evidence") }

        # TODO: if the file is truely uploaded the `attachment.document.filename` (original file name) will be displayed
        it "displays the name of the uploaded file on the page" do
          expect(response.body).to include("bank_statement_evidence")
        end
      end
    end
  end

  describe "GET /providers/applications/:legal_aid_application_id/bank_statements/list" do
    subject(:request) { get list_providers_legal_aid_application_bank_statements_path(legal_aid_application) }

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

      it { expect(response).to render_template("providers/bank_statements/_uploaded_files") }
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/bank_statements" do
    subject(:request) { patch providers_legal_aid_application_bank_statements_path(legal_aid_application), params: }

    let(:draft_button) { { draft_button: "" } }
    let(:continue_button) { { continue_button: "" } }
    let(:upload_button) { { upload_button: "Upload" } }
    let(:button_clicked) { {} }

    let(:params) { { bank_statement: params_bank_statement }.merge(button_clicked) }
    let(:params_bank_statement) { { original_file: file } }

    before { login_as provider }

    context "when upload button clicked" do
      let(:button_clicked) { upload_button }
      # let(:params) { { bank_statement: params_bank_statement }.merge(button_clicked) }

      context "with acceptable bank statement" do
        let(:file) { uploaded_file("spec/fixtures/files/documents/hello_world.pdf", "application/pdf", binary: true) }

        it "adds an attachment object" do
          expect { request }.to change(legal_aid_application.attachments, :count).by(1)
        end

        it "adds a bank_statement object" do
          expect { request }.to change(legal_aid_application.bank_statements, :count).by(1)
        end

        it "stores the original filename" do
          request
          expect(legal_aid_application.reload.attachments.first.original_filename).to eq "acceptable.pdf"
        end

        it "returns http success" do
          request
          expect(response).to have_http_status(:ok)
        end
      end

      context "when file to big" do
        let(:file) { uploaded_file("spec/fixtures/files/too_large.pdf", "application/pdf") }

        it "does not add attachment object" do
          expect { request }.not_to change(legal_aid_application.attachments, :count)
        end

        it "does not add a bank_statement object" do
          expect { request }.not_to change(legal_aid_application.bank_statements, :count)
        end

        it "returns http success" do
          request
          expect(response).to have_http_status(:ok)
        end
      end

      xcontext "and there is an error" do
        let(:original_file) { uploaded_file("spec/fixtures/files/zip.zip", "application/zip") }

        it "does not update the record" do
          request
          expect(statement_of_case).to be_nil
        end

        it "returns error message" do
          request
          error = I18n.t("#{i18n_error_path}.content_type_invalid", file_name: original_file.original_filename)
          expect(response.body).to include(error)
        end

        context "with no file chosen" do
          let(:original_file) { nil }

          it "does not update the record" do
            request
            expect(statement_of_case).to be_nil
          end

          it "returns error message" do
            request
            error = I18n.t("#{i18n_error_path}.blank")
            expect(response.body).to include(error)
          end
        end
      end

      context "when virus scanner is down" do
        before do
          malware_scan_result = instance_double(MalwareScanResult, virus_found?: false, scanner_working: false)
          allow(MalwareScanner).to receive(:call).and_return(malware_scan_result)
        end

        it "returns error message" do
          request
          error = I18n.t("#{i18n_error_path}.system_down")
          expect(response.body).to include(error)
        end
      end
    end

    xcontext "when save and continue button clicked" do
      let(:button_clicked) { continue_button }

      # TODO: this will need to change to the new provider means flow
      it "redirects to check_your_answers" do
        request
        expect(response).to redirect_to providers_legal_aid_application_check_provider_answers_path
      end

      context "and model has no files attached previously" do
        context "with no file" do
          it "fails" do
            request
            expect(response.body).to include("There is a problem")
            expect(response.body).to include(I18n.t("#{i18n_error_path}.blank"))
          end
        end

        context "when file is empty but text is entered" do
          let(:params_statement_of_case) do
            {
              statement: entered_text,
            }
          end

          it "updates the statement text" do
            request
            expect(statement_of_case.reload.statement).to eq(entered_text)
            expect(statement_of_case.original_attachments.first).not_to be_present
          end
        end

        context "when text is empty but file is present" do
          let(:entered_text) { "" }

          it "updates the file" do
            request
            expect(statement_of_case.reload.statement).to eq("")
            expect(statement_of_case.original_attachments.first).to be_present
          end
        end

        context "when file is invalid content type" do
          let(:original_file) { uploaded_file("spec/fixtures/files/zip.zip", "application/zip") }

          it "does not save the object and raise an error" do
            request
            error = I18n.t("#{i18n_error_path}.content_type_invalid", file_name: original_file.original_filename)
            expect(response.body).to include(error)
            expect(statement_of_case).to be_nil
          end
        end

        context "when file is invalid mime type but has valid content_type" do
          let(:original_file) { uploaded_file("spec/fixtures/files/zip.zip", "application/zip") }

          before do
            allow(original_file).to receive(:content_type).and_return("application/pdf")
          end

          it "does not save the object and raise an error" do
            request
            error = I18n.t("#{i18n_error_path}.content_type_invalid", file_name: original_file.original_filename)
            expect(response.body).to include(error)
            expect(statement_of_case).to be_nil
          end
        end

        context "when file is too big" do
          before { allow(StatementOfCases::StatementOfCaseForm).to receive(:max_file_size).and_return(0) }

          it "does not save the object and raise an error" do
            request
            error = I18n.t("#{i18n_error_path}.file_too_big", size: 0, file_name: original_file.original_filename)
            expect(response.body).to include(error)
            expect(statement_of_case).to be_nil
          end
        end

        context "when file is empty" do
          let(:original_file) { uploaded_file("spec/fixtures/files/empty_file.pdf", "application/pdf") }

          it "does not save the object and raise an error" do
            request
            error = I18n.t("#{i18n_error_path}.file_empty", file_name: original_file.original_filename)
            expect(response.body).to include(error)
            expect(statement_of_case).to be_nil
          end
        end

        context "when an error occurs" do
          let(:entered_text) { "" }
          let(:original_file) { nil }

          it "returns http success" do
            request
            expect(response).to have_http_status(:ok)
          end

          it "displays error" do
            request
            expect(response.body).to match 'id="application-merits-task-statement-of-case-original-file-error"'
          end

          context "when file contains a malware" do
            let(:original_file) { uploaded_file("spec/fixtures/files/malware.doc") }

            it "does not save the object and raise an error" do
              request
              error = I18n.t("#{i18n_error_path}.file_virus", file_name: original_file.original_filename)
              expect(response.body).to include(error)
              expect(statement_of_case).to be_nil
            end
          end
        end
      end

      context "when model already has files attached" do
        before { create :statement_of_case, :with_empty_text, :with_original_file_attached, legal_aid_application: }

        context "and text is empty" do
          let(:entered_text) { "" }

          context "with no additional file uploaded" do
            let(:params_statement_of_case) do
              {
                statement: entered_text,
              }
            end

            it "does not alter the record" do
              request
              expect(statement_of_case.reload.statement).to eq("")
              expect(statement_of_case.original_attachments.count).to eq 1
            end
          end

          context "when additional file uploaded" do
            it "attaches the file" do
              request
              expect(statement_of_case.reload.statement).to eq("")
              expect(statement_of_case.original_attachments.count).to eq 3
            end
          end
        end

        context "when text is entered and an additional file is uploaded" do
          let(:entered_text) { "Now we have two attached files" }

          it "updates the text and attaches the additional file" do
            request
            expect(statement_of_case.reload.statement).to eq entered_text
            expect(statement_of_case.original_attachments.count).to eq 3
          end
        end
      end
    end

    context "when save and come back later is clicked" do
      let(:button_clicked) { draft_button }

      context "when no file uploaded successfully" do
        it "blah blah blah" do
          expect(legal_aid_application.attachments).to be_empty
          expect(legal_aid_application.bank_statements).to be_empty
        end

        it "displays error that a bank statement is required" do
          request
          expect(response.body).to include("There is a problem").and include("at least one bank statement must be uploaded")
        end

        it "renders itself again" do
          request
          expect(response).to render_template(:show)
        end
      end

      context "when a file has been successfully uploaded" do
        let(:file) { uploaded_file("spec/fixtures/files/documents/hello_world.pdf", "application/pdf") }

        before do
          post v1_bank_statements_path, params: { legal_aid_application_id: id, file: }
          # TODO: this should be positive
          # expect(legal_aid_application.reload.attachments).not_to be_empty
          # expect(legal_aid_application.reload.bank_statements).not_to be_empty
        end

        # TODO: should we not test an actual endpoint being reached, as below, rather than thay defined elsewhere
        it "redirects to provider draft endpoint" do
          request
          expect(response).to redirect_to provider_draft_endpoint
        end

        # OR
        it "redirects to provider\'s application list" do
          request
          expect(response).to redirect_to providers_legal_aid_applications_path
        end
      end
    end
  end

  # xdescribe "DELETE /providers/applications/:legal_aid_application_id/bank_statements" do
  #   subject(:request) { delete providers_legal_aid_application_statement_of_case_path(legal_aid_application), params: }

  #   let(:statement_of_case) { create :statement_of_case, :with_original_file_attached }
  #   let(:legal_aid_application) { statement_of_case.legal_aid_application }
  #   let(:original_file) { statement_of_case.original_attachments.first }
  #   let(:params) { { attachment_id: statement_of_case.original_attachments.first.id } }

  #   before do
  #     login_as provider
  #   end

  #   shared_examples_for "deleting a file" do
  #     context "when only original file exists" do
  #       it "deletes the file" do
  #         attachment_id = original_file.id
  #         expect { request }.to change(Attachment, :count).by(-1)
  #         expect(Attachment.exists?(attachment_id)).to be(false)
  #       end
  #     end

  #     context "when a PDF exists" do
  #       let(:statement_of_case) { create :statement_of_case, :with_original_and_pdf_files_attached }

  #       it "deletes both attachments" do
  #         expect { request }.to change(Attachment, :count).by(-2)
  #       end
  #     end
  #   end

  #   it "returns http success" do
  #     request
  #     expect(response).to have_http_status(:ok)
  #   end

  #   context "when file not found" do
  #     let(:params) { { attachment_id: :unknown } }

  #     it "returns http success" do
  #       request
  #       expect(response).to have_http_status(:ok)
  #     end
  #   end

  #   it_behaves_like "deleting a file"
  # end
end
