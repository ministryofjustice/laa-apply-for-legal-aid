require 'rails_helper'
require 'sidekiq/testing'

module Providers
  RSpec.describe GatewayEvidencesController, type: :request do
    let(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types }
    let(:provider) { legal_aid_application.provider }
    let(:i18n_error_path) { 'activemodel.errors.models.gateway_evidence.attributes.original_file' }

    describe 'GET /providers/applications/:legal_aid_application_id/gateway_evidence' do
      subject { get providers_legal_aid_application_gateway_evidence_path(legal_aid_application) }

      context 'when the provider is not authenticated' do
        before { subject }
        it_behaves_like 'a provider not authenticated'
      end

      context 'when the provider is authenticated' do
        before do
          legal_aid_application.gateway_evidence = nil
          login_as provider
          subject
        end

        it 'returns http success' do
          expect(response).to have_http_status(:ok)
        end

        it 'does not display error' do
          expect(response.body).not_to match 'id="gateway_evidence-original-file-error"'
        end
      end
    end

    describe 'PATCH /providers/applications/:legal_aid_application_id/gateway_evidence' do
      let(:original_file) { uploaded_file('spec/fixtures/files/documents/hello_world.pdf', 'application/pdf') }
      let(:gateway_evidence) { legal_aid_application.gateway_evidence }
      let(:params_gateway_evidence) do
        {
          original_file: original_file
        }
      end
      let(:draft_button) { { draft_button: 'Save as draft' } }
      let(:upload_button) { { upload_button: 'Upload' } }
      let(:button_clicked) { {} }
      let(:params) { { gateway_evidence: params_gateway_evidence }.merge(button_clicked) }

      subject { patch providers_legal_aid_application_gateway_evidence_path(legal_aid_application), params: params }

      before { login_as provider }

      it 'updates the record' do
        subject
        expect(gateway_evidence.original_attachments.first).to be_present
      end

      it 'redirects to the next page' do
        subject
        expect(response).to redirect_to providers_legal_aid_application_check_merits_answers_path(legal_aid_application)
      end

      context 'upload button pressed' do
        let(:params_gateway_evidence) do
          {
            original_file: original_file
          }
        end
        let(:button_clicked) { upload_button }

        it 'updates the record' do
          subject
          expect(gateway_evidence.original_attachments.count).to eq(1)
        end

        it 'returns http success' do
          subject
          expect(response).to have_http_status(:ok)
        end

        context 'word document' do
          let(:original_file) { uploaded_file('spec/fixtures/files/documents/hello_world.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }

          it 'updates the record' do
            subject
            expect(gateway_evidence.original_attachments.first).to be_present
          end

          context 'when gateway_evidence file already exists' do
            let!(:gateway_evidence) { create :gateway_evidence, :with_multiple_files_attached, legal_aid_application: legal_aid_application }

            it 'updates the record' do
              subject
              expect(gateway_evidence.original_attachments.count).to eq 4
            end

            it 'increments the attachment filename' do
              subject
              attachment_names = gateway_evidence.original_attachments.map(&:attachment_name)
              expect(attachment_names).to include('gateway_evidence_4')
            end
          end

          it 'has the relevant content type' do
            subject
            document = gateway_evidence.original_attachments.first.document
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
            expect(gateway_evidence).to be_nil
          end

          it 'returns error message' do
            subject
            error = I18n.t("#{i18n_error_path}.content_type_invalid")
            expect(response.body).to include(error)
          end
        end

        context 'no file chosen' do
          let(:original_file) { nil }

          it 'does not update the record' do
            subject
            expect(gateway_evidence).to be_nil
          end

          it 'return error message' do
            subject
            error = I18n.t("#{i18n_error_path}.no_file_chosen")
            expect(response.body).to include(error)
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
          context 'file is invalid content type' do
            let(:original_file) { uploaded_file('spec/fixtures/files/zip.zip', 'application/zip') }

            it 'does not save the object and raise an error' do
              subject
              error = I18n.t("#{i18n_error_path}.content_type_invalid", file_name: original_file.original_filename)
              expect(response.body).to include(error)
              expect(gateway_evidence).to be_nil
            end
          end

          context 'no files chosen' do
            let(:original_file) { nil }

            it 'does not add a record' do
              subject
              expect(legal_aid_application.gateway_evidence).to be_nil
            end

            it 'redirects to the next page' do
              subject
              expect(response).to redirect_to providers_legal_aid_application_check_merits_answers_path(legal_aid_application)
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
              expect(gateway_evidence).to be_nil
            end
          end

          context 'file is too big' do
            before { allow(File).to receive(:size).and_return(9_437_184) }

            it 'does not save the object and raise an error' do
              subject
              error = I18n.t("#{i18n_error_path}.file_too_big", size: 7, file_name: original_file.original_filename)
              expect(response.body).to include(error)
              expect(gateway_evidence).to be_nil
            end
          end

          context 'file is empty' do
            let(:original_file) { uploaded_file('spec/fixtures/files/empty_file.pdf', 'application/pdf') }

            it 'does not save the object and raise an error' do
              subject
              error = I18n.t("#{i18n_error_path}.file_empty", file_name: original_file.original_filename)
              expect(response.body).to include(error)
              expect(gateway_evidence).to be_nil
            end
          end

          context 'file contains a malware' do
            let(:original_file) { uploaded_file('spec/fixtures/files/malware.doc') }

            it 'does not save the object and raise an error' do
              subject
              error = I18n.t("#{i18n_error_path}.file_virus", file_name: original_file.original_filename)
              expect(response.body).to include(error)
              expect(gateway_evidence).to be_nil
            end
          end
        end

        context 'model already has files attached' do
          before { create :gateway_evidence, :with_original_file_attached, legal_aid_application: legal_aid_application }

          context 'additional file uploaded' do
            it 'attaches the file' do
              subject
              expect(gateway_evidence.original_attachments.count).to eq 2
            end
          end
        end
      end

      context 'Save as draft' do
        let(:button_clicked) { draft_button }

        it 'updates the record' do
          subject
          expect(gateway_evidence.original_attachments.first).to be_present
        end

        it 'redirects to provider draft endpoint' do
          subject
          expect(response).to redirect_to provider_draft_endpoint
        end

        context 'nothing specified' do
          let(:original_file) { nil }

          it 'redirects to provider draft endpoint' do
            subject
            expect(response).to redirect_to provider_draft_endpoint
          end
        end
      end
    end

    describe 'DELETE /providers/applications/:legal_aid_application_id/gateway_evidence' do
      let(:gateway_evidence) { create :gateway_evidence, :with_original_file_attached }
      let(:legal_aid_application) { gateway_evidence.legal_aid_application }
      let(:original_file) { gateway_evidence.original_attachments.first }
      let(:params) { { attachment_id: gateway_evidence.original_attachments.first.id } }
      subject { delete providers_legal_aid_application_gateway_evidence_path(legal_aid_application), params: params }

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
          let(:gateway_evidence) { create :gateway_evidence, :with_original_and_pdf_files_attached }

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
