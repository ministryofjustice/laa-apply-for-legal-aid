require 'rails_helper'

RSpec.describe 'POST /v1/statement_of_case', type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_multiple_proceeding_types_inc_section8 }
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
