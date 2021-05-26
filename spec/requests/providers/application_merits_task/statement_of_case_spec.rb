require 'rails_helper'
require 'sidekiq/testing'

module Providers
  module ApplicationMeritsTask
    RSpec.describe StatementOfCasesController, type: :request do
      let(:legal_aid_application) { create :legal_aid_application, :with_multiple_proceeding_types_inc_section8 }
      # let(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types, :with_chances_of_success }
      let(:provider) { legal_aid_application.provider }
      let(:soc) { nil }
      let(:i18n_error_path) { 'activemodel.errors.models.application_merits_task/statement_of_case.attributes.original_file' }
      let(:smtl) { create :legal_framework_merits_task_list, legal_aid_application: legal_aid_application }
      let(:application_proceeding_type) do
        create :application_proceeding_type,
               legal_aid_application: legal_aid_application,
               proceeding_type: create(:proceeding_type, :as_section_8_child_residence)
      end

      describe 'GET /providers/applications/:legal_aid_application_id/statement_of_case' do
        subject { get providers_legal_aid_application_statement_of_case_path(legal_aid_application) }

        context 'when the provider is not authenticated' do
          before { subject }
          it_behaves_like 'a provider not authenticated'
        end

        context 'when the provider is authenticated' do
          before do
            legal_aid_application.statement_of_case = soc
            login_as provider
            subject
          end

          it 'returns http success' do
            expect(response).to have_http_status(:ok)
          end

          it 'does not display error' do
            expect(response.body).not_to match 'id="application-merits-task-statement-of-case-original-file-error"'
          end

          context 'no statement of case record exists for the application' do
            it 'displays an empty text box' do
              expect(legal_aid_application.statement_of_case).to be nil
              expect(response.body).to have_text_area_with_id_and_content('application-merits-task-statement-of-case-statement-field', '')
            end
          end

          context 'statement of case record already exists for the application' do
            let(:soc) { legal_aid_application.create_statement_of_case(statement: 'This is my case statement') }
            it 'displays the details of the statement on the page' do
              expect(response.body).to have_text_area_with_id_and_content('application-merits-task-statement-of-case-statement-field', soc.statement)
            end
          end
        end
      end

      describe 'PATCH /providers/applications/:legal_aid_application_id/statement_of_case' do
        let(:entered_text) { Faker::Lorem.paragraph(sentence_count: 3) }
        let(:original_file) { uploaded_file('spec/fixtures/files/documents/hello_world.pdf', 'application/pdf') }
        let(:statement_of_case) { legal_aid_application.statement_of_case }
        let(:params_statement_of_case) do
          {
            statement: entered_text,
            original_file: original_file
          }
        end
        let(:draft_button) { { draft_button: 'Save as draft' } }
        let(:upload_button) { { upload_button: 'Upload' } }
        let(:button_clicked) { {} }
        let(:params) { { application_merits_task_statement_of_case: params_statement_of_case }.merge(button_clicked) }

        subject { patch providers_legal_aid_application_statement_of_case_path(legal_aid_application), params: params }

        before do
          allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
          login_as provider
        end

        it 'updates the record' do
          subject
          expect(statement_of_case.reload.statement).to eq(entered_text)
          expect(statement_of_case.original_attachments.first).to be_present
        end

        describe 'redirect on success' do
          context 'when the multi-proceeding flag is true' do
            before { allow(Setting).to receive(:allow_multiple_proceedings?).and_return(true) }

            context 'and the application has a section 8 proceeding type' do
              let(:legal_aid_application) { create :legal_aid_application, :with_multiple_proceeding_types_inc_section8 }

              context 'and involved children exist' do
                before { create :involved_child, legal_aid_application: legal_aid_application }

                it 'redirects to the next page' do
                  subject
                  expect(response).to redirect_to providers_legal_aid_application_has_other_involved_children_path(legal_aid_application)
                end

                it 'sets the task to complete' do
                  subject
                  expect(legal_aid_application.legal_framework_merits_task_list.serialized_data).to match(/name: :statement_of_case\n\s+dependencies: \*\d\n\s+state: :complete/)
                end
              end

              context 'and no involved children exist' do
                it 'redirects to the next page' do
                  subject
                  expect(response).to redirect_to new_providers_legal_aid_application_involved_child_path(legal_aid_application)
                end
              end
            end
          end

          it 'redirects to the next page' do
            subject
            apt = legal_aid_application.lead_application_proceeding_type
            expect(response).to redirect_to providers_merits_task_list_chances_of_success_index_path(apt)
          end
        end

        context 'uploading a file' do
          let(:params_statement_of_case) do
            {
              original_file: original_file
            }
          end
          let(:button_clicked) { upload_button }

          it 'updates the record' do
            subject
            expect(statement_of_case.original_attachments.first).to be_present
          end

          it 'returns http success' do
            subject
            expect(response).to have_http_status(:ok)
          end

          context 'word document' do
            let(:original_file) { uploaded_file('spec/fixtures/files/documents/hello_world.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }
            let(:button_clicked) { upload_button }

            it 'updates the record' do
              subject
              expect(statement_of_case.original_attachments.first).to be_present
            end

            it 'has the relevant content type' do
              subject
              document = statement_of_case.original_attachments.first.document
              expect(document.content_type).to eq 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
            end

            it 'returns http success' do
              subject
              expect(response).to have_http_status(:ok)
            end
          end

          context 'and there is an error' do
            let(:original_file) { uploaded_file('spec/fixtures/files/zip.zip', 'application/zip') }

            it 'does not update the record' do
              subject
              expect(statement_of_case).to be_nil
            end

            it 'returns error message' do
              subject
              error = I18n.t("#{i18n_error_path}.content_type_invalid")
              expect(response.body).to include(error)
            end

            context 'no file chosen' do
              let(:original_file) { nil }

              it 'does not update the record' do
                subject
                expect(statement_of_case).to be_nil
              end

              it 'returns error message' do
                subject
                error = I18n.t("#{i18n_error_path}.blank")
                expect(response.body).to include(error)
              end
            end
          end

          context 'virus scanner is down' do
            before do
              allow_any_instance_of(MalwareScanResult).to receive(:scanner_working).with(any_args).and_return(false)
            end

            it 'returns error message' do
              subject
              error = I18n.t("#{i18n_error_path}.system_down")
              expect(response.body).to include(error)
            end
          end
        end

        context 'Continue button pressed' do
          context 'model has no files attached previously' do
            context 'file is empty and text is empty' do
              let(:params_statement_of_case) do
                {
                  statement: ''
                }
              end

              it 'fails' do
                subject
                expect(response.body).to include('There is a problem')
                expect(response.body).to include(I18n.t("#{i18n_error_path}.blank"))
              end
            end

            context 'file is empty but text is entered' do
              let(:params_statement_of_case) do
                {
                  statement: entered_text
                }
              end

              it 'updates the statement text' do
                subject
                expect(statement_of_case.reload.statement).to eq(entered_text)
                expect(statement_of_case.original_attachments.first).not_to be_present
              end
            end

            context 'text is empty but file is present' do
              let(:entered_text) { '' }

              it 'updates the file' do
                subject
                expect(statement_of_case.reload.statement).to eq('')
                expect(statement_of_case.original_attachments.first).to be_present
              end
            end

            context 'file is invalid content type' do
              let(:original_file) { uploaded_file('spec/fixtures/files/zip.zip', 'application/zip') }

              it 'does not save the object and raise an error' do
                subject
                error = I18n.t("#{i18n_error_path}.content_type_invalid", file_name: original_file.original_filename)
                expect(response.body).to include(error)
                expect(statement_of_case).to be_nil
              end
            end

            context 'file is invalid mime type but has valid content_type' do
              let(:original_file) { uploaded_file('spec/fixtures/files/zip.zip', 'application/zip') }
              before do
                allow(original_file).to receive(:content_type).and_return('application/pdf')
              end

              it 'does not save the object and raise an error' do
                subject
                error = I18n.t("#{i18n_error_path}.content_type_invalid", file_name: original_file.original_filename)
                expect(response.body).to include(error)
                expect(statement_of_case).to be_nil
              end
            end

            context 'file is too big' do
              before { allow(StatementOfCases::StatementOfCaseForm).to receive(:max_file_size).and_return(0) }

              it 'does not save the object and raise an error' do
                subject
                error = I18n.t("#{i18n_error_path}.file_too_big", size: 0, file_name: original_file.original_filename)
                expect(response.body).to include(error)
                expect(statement_of_case).to be_nil
              end
            end

            context 'file is empty' do
              let(:original_file) { uploaded_file('spec/fixtures/files/empty_file.pdf', 'application/pdf') }

              it 'does not save the object and raise an error' do
                subject
                error = I18n.t("#{i18n_error_path}.file_empty", file_name: original_file.original_filename)
                expect(response.body).to include(error)
                expect(statement_of_case).to be_nil
              end
            end

            context 'on error' do
              let(:entered_text) { '' }
              let(:original_file) { nil }

              it 'returns http success' do
                subject
                expect(response).to have_http_status(:ok)
              end

              it 'displays error' do
                subject
                expect(response.body).to match 'id="application-merits-task-statement-of-case-original-file-error"'
              end

              context 'file contains a malware' do
                let(:original_file) { uploaded_file('spec/fixtures/files/malware.doc') }

                it 'does not save the object and raise an error' do
                  subject
                  error = I18n.t("#{i18n_error_path}.file_virus", file_name: original_file.original_filename)
                  expect(response.body).to include(error)
                  expect(statement_of_case).to be_nil
                end
              end
            end
          end

          context 'model already has files attached' do
            before { create :statement_of_case, :with_empty_text, :with_original_file_attached, legal_aid_application: legal_aid_application }

            context 'text is empty' do
              let(:entered_text) { '' }

              context 'no additional file uploaded' do
                let(:params_statement_of_case) do
                  {
                    statement: entered_text
                  }
                end

                it 'does not alter the record' do
                  subject
                  expect(statement_of_case.reload.statement).to eq('')
                  expect(statement_of_case.original_attachments.count).to eq 1
                end
              end

              context 'additional file uploaded' do
                it 'attaches the file' do
                  subject
                  expect(statement_of_case.reload.statement).to eq('')
                  expect(statement_of_case.original_attachments.count).to eq 3
                end
              end
            end

            context 'text is entered and an additional file is uploaded' do
              let(:entered_text) { 'Now we have two attached files' }
              it 'updates the text and attaches  the additional file' do
                subject
                expect(statement_of_case.reload.statement).to eq entered_text
                expect(statement_of_case.original_attachments.count).to eq 3
              end
            end
          end
        end

        context 'Save as draft' do
          let(:button_clicked) { draft_button }

          it 'updates the record' do
            subject
            expect(statement_of_case.reload.statement).to eq(entered_text)
            expect(statement_of_case.original_attachments.first).to be_present
          end

          context 'when the multi-proceeding flag is true' do
            before { allow(Setting).to receive(:allow_multiple_proceedings?).and_return(true) }

            it 'does not set the task to complete' do
              subject
              expect(legal_aid_application.legal_framework_merits_task_list.serialized_data).to match(/name: :statement_of_case\n\s+dependencies: \*\d\n\s+state: :not_started/)
            end
          end

          it 'redirects to provider draft endpoint' do
            subject
            expect(response).to redirect_to provider_draft_endpoint
          end

          context 'nothing specified' do
            let(:entered_text) { '' }
            let(:original_file) { nil }

            it 'redirects to provider draft endpoint' do
              subject
              expect(response).to redirect_to provider_draft_endpoint
            end
          end
        end
      end

      describe 'DELETE /providers/applications/:legal_aid_application_id/statement_of_case' do
        let(:statement_of_case) { create :statement_of_case, :with_original_file_attached }
        let(:legal_aid_application) { statement_of_case.legal_aid_application }
        let(:original_file) { statement_of_case.original_attachments.first }
        let(:params) { { attachment_id: statement_of_case.original_attachments.first.id } }
        subject { delete providers_legal_aid_application_statement_of_case_path(legal_aid_application), params: params }

        before do
          login_as provider
        end

        shared_examples_for 'deleting a file' do
          context 'when only original file exists' do
            it 'deletes the file' do
              attachment_id = original_file.id
              expect { subject }.to change { Attachment.count }.by(-1)
              expect(Attachment.exists?(attachment_id)).to be(false)
            end
          end

          context 'when a PDF exists' do
            let(:statement_of_case) { create :statement_of_case, :with_original_and_pdf_files_attached }

            it 'deletes both attachments' do
              expect { subject }.to change { Attachment.count }.by(-2)
            end
          end
        end

        it 'returns http success' do
          subject
          expect(response).to have_http_status(:ok)
        end

        context 'when file not found' do
          let(:params) { { attachment_id: :unknown } }

          it 'returns http success' do
            subject
            expect(response).to have_http_status(:ok)
          end
        end

        it_behaves_like 'deleting a file'
      end
    end
  end
end
