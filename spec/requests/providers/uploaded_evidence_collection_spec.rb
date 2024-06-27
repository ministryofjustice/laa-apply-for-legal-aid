require "rails_helper"
require "sidekiq/testing"

module Providers
  RSpec.describe UploadedEvidenceCollectionsController do
    let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_proceedings) }
    let(:provider) { legal_aid_application.provider }
    let(:i18n_error_path) { "activemodel.errors.models.uploaded_evidence_collection.attributes.original_file" }

    describe "GET /providers/applications/:legal_aid_application_id/uploaded_evidence_collection" do
      subject(:get_request) { get providers_legal_aid_application_uploaded_evidence_collection_path(legal_aid_application) }

      context "when the provider is not authenticated" do
        before { get_request }

        it_behaves_like "a provider not authenticated"
      end

      context "when the provider is authenticated" do
        before do
          legal_aid_application.uploaded_evidence_collection = nil
          login_as provider
          get_request
        end

        it "returns http success" do
          expect(response).to have_http_status(:ok)
        end

        it "does not display error" do
          expect(unescaped_response_body).not_to match 'id="uploaded_evidence_collection-original-file-error"'
        end
      end
    end

    describe "GET /providers/applications/:legal_aid_application_id/uploaded_evidence_collection/list" do
      subject(:get_request) { get list_providers_legal_aid_application_uploaded_evidence_collection_path(legal_aid_application) }

      context "when the provider is not authenticated" do
        before { get_request }

        it_behaves_like "a provider not authenticated"
      end

      context "when the provider is authenticated" do
        before do
          legal_aid_application.uploaded_evidence_collection = nil
          login_as provider
          get_request
        end

        it "returns http success" do
          expect(response).to have_http_status(:ok)
        end
      end
    end

    describe "PATCH /providers/applications/:legal_aid_application_id/uploaded_evidence_collection" do
      subject(:patch_request) { patch providers_legal_aid_application_uploaded_evidence_collection_path(legal_aid_application), params: }

      let(:original_file) { uploaded_file("spec/fixtures/files/documents/hello_world.pdf", "application/pdf") }
      let(:uploaded_evidence_collection) { legal_aid_application.uploaded_evidence_collection }
      let(:params_uploaded_evidence_collection) do
        {
          original_file:,
        }
      end
      let(:draft_button) { { draft_button: "Save as draft" } }
      let(:upload_button) { { upload_button: "Upload" } }
      let(:delete_button) { { delete_button: "" } }
      let(:continue_button) { { continue_button: "Save and continue" } }
      let(:button_clicked) { {} }
      let(:params) { { uploaded_evidence_collection: params_uploaded_evidence_collection }.merge(button_clicked) }

      before { login_as provider }

      context "when the upload button is pressed" do
        let(:params_uploaded_evidence_collection) do
          {
            original_file:,
          }
        end
        let(:button_clicked) { upload_button }

        it "updates the record" do
          patch_request
          legal_aid_application.reload
          expect(uploaded_evidence_collection.original_attachments.count).to eq(1)
        end

        it "stores the original filename" do
          patch_request
          legal_aid_application.reload
          attachment = uploaded_evidence_collection.original_attachments.first
          expect(attachment.original_filename).to eq "hello_world.pdf"
        end

        it "returns http success" do
          patch_request
          expect(response).to have_http_status(:ok)
        end

        context "when a word document is selected" do
          let(:original_file) { uploaded_file("spec/fixtures/files/documents/hello_world.docx", "application/vnd.openxmlformats-officedocument.wordprocessingml.document") }

          it "updates the record" do
            patch_request
            expect(uploaded_evidence_collection.original_attachments.first).to be_present
          end

          context "when uploaded_evidence_collection file already exists" do
            let!(:uploaded_evidence_collection) { create(:uploaded_evidence_collection, :with_multiple_files_attached, legal_aid_application:) }

            it "updates the record" do
              patch_request
              expect(uploaded_evidence_collection.original_attachments.count).to eq 4
            end

            it "increments the attachment filename" do
              patch_request
              attachment_names = uploaded_evidence_collection.original_attachments.map(&:attachment_name)
              expect(attachment_names).to include("uploaded_evidence_collection_4")
            end
          end

          it "has the relevant content type" do
            patch_request
            document = uploaded_evidence_collection.original_attachments.first.document
            expect(document.content_type).to eq "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
          end

          it "returns http success" do
            patch_request
            expect(response).to have_http_status(:ok)
          end
        end

        context "when an invalid file type is uploaded" do
          let(:original_file) { uploaded_file("spec/fixtures/files/zip.zip", "application/zip") }

          it "does not update the record" do
            uploaded_evidence_collection
            patch_request
            expect(uploaded_evidence_collection).to be_nil
          end

          it "returns error message" do
            patch_request
            error = I18n.t("#{i18n_error_path}.content_type_invalid")
            expect(unescaped_response_body).to include(error)
          end
        end

        context "when an invalid mime type but valid content_type is uploaded" do
          let(:original_file) { uploaded_file("spec/fixtures/files/zip.zip", "application/zip") }

          before do
            allow(original_file).to receive(:content_type).and_return("application/pdf")
          end

          it "does not save the object and raises an error" do
            uploaded_evidence_collection
            patch_request
            error = I18n.t("#{i18n_error_path}.content_type_invalid", file_name: original_file.original_filename)
            expect(unescaped_response_body).to include(error)
            expect(uploaded_evidence_collection).to be_nil
          end
        end

        context "when a file with an invalid file header is uploaded" do
          let(:original_file) { uploaded_file("spec/fixtures/files/documents/hello_world.docx", "application/vnd.openxmlformats-officedocument.wordprocessingml.document") }

          before do
            allow_any_instance_of(ActionDispatch::Http::UploadedFile).to receive(:headers).and_return("\xC3hello_world.docx".force_encoding(Encoding::ASCII_8BIT))
          end

          it "updates the record" do
            patch_request
            expect(uploaded_evidence_collection.original_attachments.first).to be_present
          end
        end

        context "when a file that is too big is uploaded" do
          before { allow(File).to receive(:size).and_return(9_437_184) }

          it "does not save the object and raises an error" do
            uploaded_evidence_collection
            patch_request
            error = I18n.t("#{i18n_error_path}.file_too_big", size: 7, file_name: original_file.original_filename)
            expect(unescaped_response_body).to include(error)
            expect(uploaded_evidence_collection).to be_nil
          end
        end

        context "when a file that contains malware is uploaded", :clamav do
          let(:original_file) { uploaded_file("spec/fixtures/files/malware.doc") }

          it "does not save the object and raises an error" do
            uploaded_evidence_collection
            patch_request
            error = I18n.t("#{i18n_error_path}.file_virus", file_name: original_file.original_filename)
            expect(unescaped_response_body).to include(error)
            expect(uploaded_evidence_collection).to be_nil
          end
        end

        context "when a file that is empty is uploaded" do
          let(:original_file) { uploaded_file("spec/fixtures/files/empty_file.pdf", "application/pdf") }

          it "does not save the object and raises an error" do
            uploaded_evidence_collection
            patch_request
            error = I18n.t("#{i18n_error_path}.file_empty", file_name: original_file.original_filename)
            expect(unescaped_response_body).to include(error)
            expect(uploaded_evidence_collection).to be_nil
          end
        end

        context "when no file chosen" do
          let(:original_file) { nil }

          it "does not update the record" do
            uploaded_evidence_collection
            patch_request
            expect(uploaded_evidence_collection).to be_nil
          end

          it "return error message" do
            patch_request
            error = I18n.t("#{i18n_error_path}.no_file_chosen")
            expect(unescaped_response_body).to include(error)
          end
        end

        context "when virus scanner is down" do
          before do
            allow_any_instance_of(MalwareScanResult).to receive(:scanner_working).with(any_args).and_return(false)
          end

          it "returns error message" do
            patch_request
            error = I18n.t("#{i18n_error_path}.system_down")
            expect(unescaped_response_body).to include(error)
          end
        end
      end

      context "when Continue button pressed" do
        let(:button_clicked) { continue_button }

        context "and model has no files attached previously" do
          context "and no files uploaded" do
            let(:params_uploaded_evidence_collection) { {} }

            it "does not add a record" do
              patch_request
              expect(legal_aid_application.uploaded_evidence_collection).to be_nil
            end

            context "when no mandatory evidence is required" do
              it "redirects to the next page" do
                patch_request
                expect(response).to have_http_status(:redirect)
              end
            end

            context "when mandatory evidence is missing" do
              let(:attachment_type) { "gateway_evidence" }
              let(:missing_categories) { [] }

              before do
                create(:dwp_override, legal_aid_application:)
                allow(DocumentCategory).to receive(:displayable_document_category_names).and_return(missing_categories)
                allow(legal_aid_application).to receive(:required_document_categories).and_return(missing_categories)
                allow_any_instance_of(UploadedEvidenceCollection).to receive(:mandatory_evidence_types).and_return(missing_categories)
                legal_aid_application.reload
              end

              context "when benefits evidence is required" do
                let(:missing_categories) { %w[benefit_evidence] }

                it "raises an error" do
                  patch_request
                  error = I18n.t("#{i18n_error_path}.benefit_evidence_missing", benefit: "Universal Credit")
                  expect(unescaped_response_body).to include(error)
                end
              end

              context "when employment evidence is required" do
                let(:missing_categories) { %w[client_employment_evidence] }

                it "raises an error" do
                  patch_request
                  error = I18n.t("#{i18n_error_path}.client_employment_evidence_missing")
                  expect(unescaped_response_body).to include(error)
                end
              end
            end
          end

          context "when a file is uploaded" do
            let(:attachment_type) { "uncategorised" }
            let(:attachment) { create(:attachment, attachment_name: "test_file.pdf", attachment_type:, legal_aid_application:) }
            let(:params_uploaded_evidence_collection) { { attachment.id.to_s => attachment.attachment_type.to_s } }

            context "when all validation rules are satisfied" do
              let(:attachment_type) { "gateway_evidence" }

              before { allow(DocumentCategory).to receive(:displayable_document_category_names).and_return(%w[gateway_evidence]) }

              it "redirects to the next page" do
                patch_request
                expect(response).to have_http_status(:redirect)
              end
            end

            context "when the file is uncategorised" do
              it "raises an error" do
                patch_request
                error = I18n.t("#{i18n_error_path}.uncategorised_evidence")
                expect(unescaped_response_body).to include(error)
              end
            end

            context "when mandatory evidence is missing" do
              let(:attachment_type) { "gateway_evidence" }
              let(:missing_categories) { [] }

              before do
                create(:dwp_override, legal_aid_application:)
                allow(DocumentCategory).to receive(:displayable_document_category_names).and_return(missing_categories)
                allow(legal_aid_application).to receive(:required_document_categories).and_return(missing_categories)
                allow_any_instance_of(UploadedEvidenceCollection).to receive(:mandatory_evidence_types).and_return(missing_categories)
                legal_aid_application.reload
              end

              context "when benefits evidence is required" do
                let(:missing_categories) { %w[benefit_evidence] }

                it "raises an error" do
                  patch_request
                  error = I18n.t("#{i18n_error_path}.benefit_evidence_missing", benefit: "Universal Credit")
                  expect(unescaped_response_body).to include(error)
                end
              end

              context "when employment evidence is required" do
                let(:missing_categories) { %w[client_employment_evidence] }

                it "raises an error" do
                  patch_request
                  error = I18n.t("#{i18n_error_path}.client_employment_evidence_missing")
                  expect(unescaped_response_body).to include(error)
                end
              end

              context "when files are uncategorised and mandatory evidence is missing" do
                let(:attachment_type) { "uncategorised" }
                let(:missing_categories) { %w[benefit_evidence] }

                it "raises two errors" do
                  patch_request
                  benefit_error = I18n.t("#{i18n_error_path}.benefit_evidence_missing", benefit: "Universal Credit")
                  uncategorised_error = I18n.t("#{i18n_error_path}.uncategorised_evidence")
                  expect(unescaped_response_body).to include(benefit_error)
                  expect(unescaped_response_body).to include(uncategorised_error)
                end
              end
            end
          end

          context "with multiple files uploaded" do
            let(:attachment_type) { "uncategorised" }
            let(:attachment1) { create(:attachment, attachment_name: "test_file1.pdf", attachment_type:, legal_aid_application:) }
            let(:attachment2) { create(:attachment, attachment_name: "test_file2.pdf", attachment_type:, legal_aid_application:) }
            let(:params_uploaded_evidence_collection) { { attachment1.id.to_s => attachment1.attachment_type.to_s, attachment2.id.to_s => attachment2.attachment_type.to_s } }

            context "when all validation rules are satisfied" do
              let(:attachment_type) { "gateway_evidence" }

              before { allow(DocumentCategory).to receive(:displayable_document_category_names).and_return(%w[gateway_evidence]) }

              it "redirects to the next page" do
                patch_request
                expect(response).to have_http_status(:redirect)
              end
            end

            context "when a file is uncategorised" do
              it "raises an error" do
                patch_request
                error = I18n.t("#{i18n_error_path}.uncategorised_evidence")
                expect(unescaped_response_body).to include(error)
              end
            end

            context "when mandatory evidence is missing" do
              before do
                create(:dwp_override, legal_aid_application:)
                allow(DocumentCategory).to receive(:displayable_document_category_names).and_return(missing_categories)
                allow(legal_aid_application).to receive(:required_document_categories).and_return(missing_categories)
                allow_any_instance_of(UploadedEvidenceCollection).to receive(:mandatory_evidence_types).and_return(missing_categories)
                legal_aid_application.reload
              end

              let(:missing_categories) { [] }

              context "when benefits evidence is required" do
                let(:missing_categories) { %w[benefit_evidence] }

                before do
                  attachment1.update!(attachment_type: "gateway_evidence")
                  attachment2.update!(attachment_type: "client_employment_evidence")
                end

                it "raises an error" do
                  patch_request
                  error = I18n.t("#{i18n_error_path}.benefit_evidence_missing", benefit: "Universal Credit")
                  expect(unescaped_response_body).to include(error)
                end
              end

              context "when client's employment evidence is required" do
                let(:missing_categories) { %w[client_employment_evidence] }

                before do
                  attachment1.update!(attachment_type: "gateway_evidence")
                  attachment2.update!(attachment_type: "benefit_evidence")
                end

                it "raises an error" do
                  patch_request
                  error = I18n.t("#{i18n_error_path}.client_employment_evidence_missing")
                  expect(unescaped_response_body).to include(error)
                end
              end

              context "when files are uncategorised and mandatory evidence is missing" do
                let(:missing_categories) { %w[benefit_evidence client_employment_evidence] }

                it "raises two errors" do
                  patch_request
                  benefit_error = I18n.t("#{i18n_error_path}.benefit_evidence_missing", benefit: "Universal Credit")
                  employment_error = I18n.t("#{i18n_error_path}.client_employment_evidence_missing")
                  uncategorised_error = I18n.t("#{i18n_error_path}.uncategorised_evidence")
                  expect(unescaped_response_body).to include(benefit_error)
                  expect(unescaped_response_body).to include(employment_error)
                  expect(unescaped_response_body).to include(uncategorised_error)
                end
              end
            end
          end
        end
      end

      context "when submitted with Save as draft" do
        let(:button_clicked) { draft_button }

        context "when no files have been uploaded" do
          it "updates the record" do
            patch_request
            expect(uploaded_evidence_collection).to be_present
          end
        end

        it "redirects to provider draft endpoint" do
          patch_request
          expect(response).to redirect_to provider_draft_endpoint
        end

        context "when nothing specified" do
          let(:original_file) { nil }

          it "redirects to provider draft endpoint" do
            patch_request
            expect(response).to redirect_to provider_draft_endpoint
          end
        end
      end

      context "when submitted with Delete" do
        subject(:patch_request) { patch providers_legal_aid_application_uploaded_evidence_collection_path(legal_aid_application), params: delete_params }

        let(:button_clicked) { delete_button }
        let(:uploaded_evidence_collection) { create(:uploaded_evidence_collection, :with_original_file_attached) }
        let(:legal_aid_application) { uploaded_evidence_collection.legal_aid_application }
        let(:original_file) { uploaded_evidence_collection.original_attachments.first }
        let(:delete_params) do
          {
            uploaded_evidence_collection: {
              uploaded_evidence_collection.original_attachments.first.id => "gateway_evidence",
            },
            delete_button: "",
            attachment_id: uploaded_evidence_collection.original_attachments.first.id,
            legal_aid_application_id: legal_aid_application.id,
          }
        end

        before do
          allow(DocumentCategory).to receive(:displayable_document_category_names).and_return(%w[gateway_evidence])
          login_as provider
        end

        it "returns http success" do
          patch_request
          expect(response).to have_http_status(:ok)
        end

        context "when only original file exists" do
          it "deletes the file" do
            attachment_id = original_file.id
            expect { patch_request }.to change(Attachment, :count).by(-1)
            expect(Attachment.exists?(attachment_id)).to be(false)
          end
        end

        context "when a PDF exists" do
          let(:uploaded_evidence_collection) { create(:uploaded_evidence_collection, :with_original_and_pdf_files_attached) }

          it "deletes both attachments" do
            expect { patch_request }.to change(Attachment, :count).by(-2)
          end
        end

        context "when file not found" do
          let(:delete_params) do
            {
              uploaded_evidence_collection: {
                uploaded_evidence_collection.original_attachments.first.id => "gateway_evidence",
              },
              delete_button: "",
              attachment_id: "unknown",
              legal_aid_application_id: legal_aid_application.id,
            }
          end

          it "returns http success" do
            patch_request
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end
  end
end
