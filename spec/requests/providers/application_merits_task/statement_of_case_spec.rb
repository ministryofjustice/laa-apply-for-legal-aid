require "rails_helper"
require "sidekiq/testing"

module Providers
  module ApplicationMeritsTask
    RSpec.describe StatementOfCasesController do
      let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8) }
      let(:provider) { legal_aid_application.provider }
      let(:soc) { nil }
      let(:smtl) { create(:legal_framework_merits_task_list, legal_aid_application:) }

      describe "GET /providers/applications/:legal_aid_application_id/statement_of_case" do
        subject(:get_request) { get providers_legal_aid_application_statement_of_case_path(legal_aid_application) }

        context "when the provider is not authenticated" do
          before { get_request }

          it_behaves_like "a provider not authenticated"
        end

        context "when the provider is authenticated" do
          before do
            legal_aid_application.statement_of_case = soc
            login_as provider
            get_request
          end

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "does not display error" do
            expect(response.body).not_to match 'id="application-merits-task-statement-of-case-original-file-error"'
          end

          context "when no statement of case record exists for the application" do
            it "displays an empty text box" do
              expect(legal_aid_application.statement_of_case).to be_nil
              expect(response.body).to have_text_area_with_id_and_content("application-merits-task-statement-of-case-statement-field", "")
            end
          end

          context "when statement of case record already exists for the application" do
            let(:soc) { legal_aid_application.create_statement_of_case(statement: "This is my case statement") }

            it "displays the details of the statement on the page" do
              expect(response.body).to have_text_area_with_id_and_content("application-merits-task-statement-of-case-statement-field", soc.statement)
            end
          end
        end
      end

      describe "GET /providers/applications/:legal_aid_application_id/statement_of_case/list" do
        subject(:get_request) { get list_providers_legal_aid_application_statement_of_case_path(legal_aid_application) }

        context "when the provider is not authenticated" do
          before { get_request }

          it_behaves_like "a provider not authenticated"
        end

        context "when the provider is authenticated" do
          before do
            legal_aid_application.statement_of_case = soc
            login_as provider
            get_request
          end

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end
        end
      end

      describe "PATCH /providers/applications/:legal_aid_application_id/statement_of_case" do
        subject(:patch_request) { patch providers_legal_aid_application_statement_of_case_path(legal_aid_application), params: }

        let(:entered_text) { Faker::Lorem.paragraph(sentence_count: 3) }
        let(:original_file) { uploaded_file("spec/fixtures/files/documents/hello_world.pdf", "application/pdf") }
        let(:statement_of_case) { legal_aid_application.statement_of_case }
        let(:params_statement_of_case) do
          {
            statement: entered_text,
            original_file:,
          }
        end
        let(:draft_button) { { draft_button: "Save as draft" } }
        let(:upload_button) { { upload_button: "Upload" } }
        let(:button_clicked) { {} }
        let(:params) { { application_merits_task_statement_of_case: params_statement_of_case }.merge(button_clicked) }

        before do
          allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
          legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :latest_incident_details)
          legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :opponent_name)
          legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :opponent_mental_capacity)
          legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :domestic_abuse_summary)
          login_as provider
        end

        it "updates the record" do
          patch_request
          expect(statement_of_case.reload.statement).to eq(entered_text)
          expect(statement_of_case.original_attachments.first).to be_present
        end

        describe "redirect on success" do
          context "when the application only has domestic abuse proceedings" do
            let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings) }
            let(:smtl) { create(:legal_framework_merits_task_list, :da001, legal_aid_application:) }

            before do
              legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :latest_incident_details)
              legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :opponent_name)
              legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :opponent_mental_capacity)
              legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :domestic_abuse_summary)
            end

            it "redirects to the next page" do
              patch_request
              expect(response).to have_http_status(:redirect)
            end
          end

          context "when the application only has domestic abuse proceedings and is a defendant" do
            let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings) }
            let(:smtl) { create(:legal_framework_merits_task_list, :da001_as_defendant, legal_aid_application:) }

            before do
              legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :latest_incident_details)
              legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :opponent_name)
              legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :opponent_mental_capacity)
              legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :domestic_abuse_summary)
            end

            it "redirects to the next page" do
              patch_request
              expect(response).to have_http_status(:redirect)
            end
          end

          context "when the application has delegated functions on one or more more proceedings" do
            let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8) }
            let(:smtl) { create(:legal_framework_merits_task_list, :da001_and_child_section_8_with_delegated_functions, legal_aid_application:) }

            before do
              legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :latest_incident_details)
              legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :opponent_name)
              legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :opponent_mental_capacity)
              legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :domestic_abuse_summary)
            end

            it "redirects to the next page" do
              patch_request
              expect(response).to have_http_status(:redirect)
            end
          end

          context "when the application has a section 8 proceeding" do
            let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, :with_multiple_proceedings_inc_section8) }

            context "and involved children exist" do
              before do
                create(:involved_child, legal_aid_application:)
                legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :latest_incident_details)
                legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :opponent_name)
                legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :opponent_mental_capacity)
                legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :domestic_abuse_summary)
              end

              it "redirects to the next page" do
                patch_request
                expect(response).to have_http_status(:redirect)
              end

              it "sets the task to complete" do
                patch_request
                expect(legal_aid_application.reload.legal_framework_merits_task_list).to have_completed_task(:application, :statement_of_case)
              end
            end

            context "and no involved children exist" do
              it "redirects to the next page" do
                patch_request
                expect(response).to have_http_status(:redirect)
              end
            end
          end
        end

        context "when uploading a file" do
          let(:params_statement_of_case) do
            {
              original_file:,
            }
          end
          let(:button_clicked) { upload_button }

          it "updates the record" do
            patch_request
            expect(statement_of_case.original_attachments.first).to be_present
          end

          it "returns http success" do
            patch_request
            expect(response).to have_http_status(:ok)
          end

          context "when the file is a csv" do
            let(:original_file) { uploaded_file("spec/fixtures/files/sample_csv.csv", "text/csv") }
            let(:button_clicked) { upload_button }

            it "does not save the object" do
              patch_request
              expect(legal_aid_application.reload.attachments.length).to match(0)
              expect(statement_of_case).to be_nil
            end

            it "returns error message" do
              patch_request
              error = "#{original_file.original_filename} must be a DOC, DOCX, RTF, ODT, JPG, BMP, PNG, TIF or PDF"
              expect(response.body).to include(error)
            end
          end

          context "when a word document" do
            let(:original_file) { uploaded_file("spec/fixtures/files/documents/hello_world.docx", "application/vnd.openxmlformats-officedocument.wordprocessingml.document") }
            let(:button_clicked) { upload_button }

            it "updates the record" do
              patch_request
              expect(statement_of_case.original_attachments.first).to be_present
            end

            it "stores the original filename" do
              patch_request
              attachment = statement_of_case.original_attachments.first
              expect(attachment.original_filename).to eq "hello_world.docx"
            end

            it "has the relevant content type" do
              patch_request
              document = statement_of_case.original_attachments.first.document
              expect(document.content_type).to eq "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
            end

            it "returns http success" do
              patch_request
              expect(response).to have_http_status(:ok)
            end
          end

          context "and there is an error" do
            let(:original_file) { uploaded_file("spec/fixtures/files/zip.zip", "application/zip") }

            it "does not update the record" do
              patch_request
              expect(statement_of_case).to be_nil
            end

            it "returns error message" do
              patch_request
              error = "#{original_file.original_filename} must be a DOC, DOCX, RTF, ODT, JPG, BMP, PNG, TIF or PDF"
              expect(response.body).to include(error)
            end

            context "with no file chosen" do
              let(:original_file) { nil }

              it "does not update the record" do
                patch_request
                expect(statement_of_case).to be_nil
              end

              it "returns error message" do
                patch_request
                expect(response.body).to include("Attach a file or enter text")
              end
            end
          end

          context "when virus scanner is down" do
            before do
              allow(MalwareScanResult).to receive(:new).and_return(malware_scan_result)
              allow(malware_scan_result).to receive(:scanner_working).with(any_args).and_return(false)
              allow(malware_scan_result).to receive(:save!)
              allow(malware_scan_result).to receive(:virus_found?)
            end

            let(:malware_scan_result) { instance_double(MalwareScanResult) }

            it "returns error message" do
              patch_request
              expect(response.body).to include("There was a problem uploading your file - try again")
            end
          end
        end

        context "when continue button pressed" do
          context "and model has no files attached previously" do
            context "and file is empty and text is empty" do
              let(:params_statement_of_case) do
                {
                  statement: "",
                }
              end

              it "fails" do
                patch_request
                expect(response.body).to include("There is a problem")
                expect(response.body).to include("Attach a file or enter text")
              end
            end

            context "when file is empty but text is entered" do
              let(:params_statement_of_case) do
                {
                  statement: entered_text,
                }
              end

              it "updates the statement text" do
                patch_request
                expect(statement_of_case.reload.statement).to eq(entered_text)
                expect(statement_of_case.original_attachments.first).not_to be_present
              end
            end

            context "when text is empty but file is present" do
              let(:entered_text) { "" }

              it "updates the file" do
                patch_request
                expect(statement_of_case.reload.statement).to eq("")
                expect(statement_of_case.original_attachments.first).to be_present
              end
            end

            context "when file is invalid content type" do
              let(:original_file) { uploaded_file("spec/fixtures/files/zip.zip", "application/zip") }

              it "does not save the object and raise an error" do
                patch_request
                error = "#{original_file.original_filename} must be a DOC, DOCX, RTF, ODT, JPG, BMP, PNG, TIF or PDF"
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
                patch_request
                error = "#{original_file.original_filename} must be a DOC, DOCX, RTF, ODT, JPG, BMP, PNG, TIF or PDF"
                expect(response.body).to include(error)
                expect(statement_of_case).to be_nil
              end
            end

            context "when file is too big" do
              before do
                allow(StatementOfCases::StatementOfCaseForm)
                  .to receive(:max_file_size).and_return(0.megabytes)
              end

              it "does not save the object and raise an error" do
                patch_request
                error = "#{original_file.original_filename} must be smaller than 0MB"
                expect(response.body).to include(error)
                expect(statement_of_case).to be_nil
              end
            end

            context "when file is empty" do
              let(:original_file) { uploaded_file("spec/fixtures/files/empty_file.pdf", "application/pdf") }

              it "does not save the object and raise an error" do
                patch_request
                error = "#{original_file.original_filename} has no content"
                expect(response.body).to include(error)
                expect(statement_of_case).to be_nil
              end
            end

            context "when an error occurs" do
              let(:entered_text) { "" }
              let(:original_file) { nil }

              it "returns http success" do
                patch_request
                expect(response).to have_http_status(:ok)
              end

              it "displays error link on statement text field" do
                patch_request
                expect(response.body).to match 'id="application-merits-task-statement-of-case-statement-error"'
              end

              context "when file contains a malware", :clamav do
                let(:original_file) { uploaded_file("spec/fixtures/files/malware.doc") }

                it "does not save the object and raise an error" do
                  patch_request
                  error = "#{original_file.original_filename} contains a virus"
                  expect(response.body).to include(error)
                  expect(statement_of_case).to be_nil
                end
              end
            end
          end

          context "when model already has files attached" do
            before { create(:statement_of_case, :with_empty_text, :with_original_file_attached, legal_aid_application:) }

            context "and text is empty" do
              let(:entered_text) { "" }

              context "with no additional file uploaded" do
                let(:params_statement_of_case) do
                  {
                    statement: entered_text,
                  }
                end

                it "does not alter the record" do
                  patch_request
                  expect(statement_of_case.reload.statement).to eq("")
                  expect(statement_of_case.original_attachments.count).to eq 1
                end
              end

              context "when additional file uploaded" do
                it "attaches the file" do
                  patch_request
                  expect(statement_of_case.reload.statement).to eq("")
                  expect(statement_of_case.original_attachments.count).to eq 3
                end
              end
            end

            context "when text is entered and an additional file is uploaded" do
              let(:entered_text) { "Now we have two attached files" }

              it "updates the text and attaches the additional file" do
                patch_request
                expect(statement_of_case.reload.statement).to eq entered_text
                expect(statement_of_case.original_attachments.count).to eq 3
              end
            end
          end
        end

        context "when save as draft is selected" do
          let(:button_clicked) { draft_button }

          it "updates the record" do
            patch_request
            expect(statement_of_case.reload.statement).to eq(entered_text)
            expect(statement_of_case.original_attachments.first).to be_present
          end

          it "does not set the task to complete" do
            patch_request
            expect(legal_aid_application.legal_framework_merits_task_list).to have_not_started_task(:application, :statement_of_case)
          end

          it "redirects to provider draft endpoint" do
            patch_request
            expect(response).to redirect_to provider_draft_endpoint
          end

          context "with nothing specified" do
            let(:entered_text) { "" }
            let(:original_file) { nil }

            it "redirects to provider draft endpoint" do
              patch_request
              expect(response).to redirect_to provider_draft_endpoint
            end
          end
        end
      end

      describe "DELETE /providers/applications/:legal_aid_application_id/statement_of_case" do
        subject(:delete_request) { delete providers_legal_aid_application_statement_of_case_path(legal_aid_application), params: }

        let(:statement_of_case) { create(:statement_of_case, :with_original_file_attached) }
        let(:legal_aid_application) { statement_of_case.legal_aid_application }
        let(:original_file) { statement_of_case.original_attachments.first }
        let(:params) { { attachment_id: statement_of_case.original_attachments.first.id } }

        before do
          login_as provider
        end

        shared_examples_for "deleting a file" do
          context "when only original file exists" do
            it "deletes the file" do
              attachment_id = original_file.id
              expect { delete_request }.to change(Attachment, :count).by(-1)
              expect(Attachment.exists?(attachment_id)).to be(false)
            end
          end

          context "when a PDF exists" do
            let(:statement_of_case) { create(:statement_of_case, :with_original_and_pdf_files_attached) }

            it "deletes both attachments" do
              expect { delete_request }.to change(Attachment, :count).by(-2)
            end
          end
        end

        it "returns http success" do
          delete_request
          expect(response).to have_http_status(:ok)
        end

        context "when file not found" do
          let(:params) { { attachment_id: :unknown } }

          it "returns http success" do
            delete_request
            expect(response).to have_http_status(:ok)
          end
        end

        it_behaves_like "deleting a file"
      end
    end
  end
end
