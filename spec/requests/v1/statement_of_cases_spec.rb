require 'rails_helper'

RSpec.describe 'POST /v1/statement_of_case', type: :request do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:id) { legal_aid_application.id }
  let(:file) { uploaded_file('spec/fixtures/files/documents/hello_world.pdf', 'application/pdf') }
  let(:params) { { legal_aid_application_id: id, file: file } }

  describe 'POST /v1/statement_of_cases' do
    subject { post v1_statement_of_cases_path, params: params }

    context 'when the application exists' do
      it 'returns http success' do
        subject
        expect(response).to have_http_status(:success)
      end

      it 'adds the statement of case to the legal aid application' do
        expect { subject }.to change { legal_aid_application.reload.attachments.length }.by 1
      end

      context 'when the application has no statement of case' do
        let(:legal_aid_application) { create :legal_aid_application, attachments: [] }

        it 'does not increment the attachment name' do
          subject
          expect(legal_aid_application.reload.attachments.length).to match(1)
          expect(legal_aid_application.reload.attachments.last.attachment_name).to match('statement_of_case')
        end
      end

      context 'when the application has one attachment for statement of case already' do
        let(:statement_of_case) { create :attachment, attachment_name: 'statement_of_case' }
        let(:legal_aid_application) { create :legal_aid_application, attachments: [statement_of_case] }

        it 'increments the attachment name' do
          subject
          expect(legal_aid_application.reload.attachments.length).to match(2)
          expect(legal_aid_application.reload.attachments.order(:attachment_name).last.attachment_name).to match('statement_of_case_1')
        end
      end

      context 'when the application has multiple attachments for statement of case already' do
        let(:soc1) { create :attachment, attachment_name: 'statement_of_case' }
        let(:soc2) { create :attachment, attachment_name: 'statement_of_case_1' }
        let(:legal_aid_application) { create :legal_aid_application, attachments: [soc1, soc2] }

        it 'increments the attachment name' do
          subject
          expect(legal_aid_application.reload.attachments.length).to match(3)
          expect(legal_aid_application.reload.attachments.order(:attachment_name).last.attachment_name).to match('statement_of_case_2')
        end
      end

      context 'file contains a malware' do
        let(:file) { uploaded_file('spec/fixtures/files/malware.doc', 'application/pdf') }
        let(:i18n_error_path) { 'activemodel.errors.models.application_merits_task/statement_of_case.attributes.original_file' }

        it 'does not save the object and raises a 500 error with text' do
          subject
          expect(legal_aid_application.reload.attachments.length).to match(0)
          expect(response.status).to eq 400
          expect(response.body).to include(I18n.t("#{i18n_error_path}.file_virus"))
        end
      end

      context 'virus scanner is down' do
        before { allow_any_instance_of(MalwareScanResult).to receive(:scanner_working).with(any_args).and_return(false) }
        let(:i18n_error_path) { 'activemodel.errors.models.application_merits_task/statement_of_case.attributes.original_file' }

        it 'does not save the object and raises a 500 error with text' do
          subject
          expect(legal_aid_application.reload.attachments.length).to match(0)
          expect(response.status).to eq 400
          expect(response.body).to include(I18n.t("#{i18n_error_path}.system_down"))
        end
      end
    end

    context 'when the application does not exist' do
      let(:id) { SecureRandom.hex }
      it 'returns http not found' do
        subject
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
