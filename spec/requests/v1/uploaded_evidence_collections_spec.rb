require 'rails_helper'

RSpec.describe 'POST /v1/uploaded_evidence_collections', type: :request do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:id) { legal_aid_application.id }
  let(:file) { uploaded_file('spec/fixtures/files/documents/hello_world.pdf', 'application/pdf') }
  let(:params) { { legal_aid_application_id: id, file: file } }

  describe 'POST /v1/uploaded_evidence_collections' do
    subject { post v1_uploaded_evidence_collections_path, params: params }

    context 'when the application exists' do
      it 'returns http success' do
        subject
        expect(response).to have_http_status(:success)
      end

      it 'adds the attachment to the legal aid application' do
        expect { subject }.to change { legal_aid_application.reload.attachments.length }.by 1
      end

      context 'when the application has no attachments' do
        let(:legal_aid_application) { create :legal_aid_application, attachments: [] }

        it 'does not increment the attachment name' do
          subject
          expect(legal_aid_application.reload.attachments.length).to match(1)
          expect(legal_aid_application.reload.attachments.last.attachment_name).to match('uploaded_evidence_collection')
        end
      end

      context 'when the application has one attachment already' do
        let(:attachment) { create :attachment, :uploaded_evidence_collection }
        let(:legal_aid_application) { create :legal_aid_application, attachments: [attachment] }

        it 'increments the attachment name' do
          subject
          expect(legal_aid_application.reload.attachments.length).to match(2)
          expect(legal_aid_application.reload.attachments.order(:attachment_name).last.attachment_name).to match('uploaded_evidence_collection_1')
        end
      end

      context 'when the application has multiple attachments for statement of case already' do
        let(:uec1) { create :attachment, :uploaded_evidence_collection }
        let(:uec2) { create :attachment, :uploaded_evidence_collection, attachment_name: 'uploaded_evidence_collection_1' }
        let(:legal_aid_application) { create :legal_aid_application, attachments: [uec1, uec2] }

        it 'increments the attachment name' do
          subject
          expect(legal_aid_application.reload.attachments.length).to match(3)
          expect(legal_aid_application.reload.attachments.order(:attachment_name).last.attachment_name).to match('uploaded_evidence_collection_2')
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
