require 'rails_helper'

RSpec.describe Admin::LegalAidApplicationsController, type: :request do
  let(:count) { 3 }
  let!(:legal_aid_applications) { create_list :legal_aid_application, count }
  let(:admin_user) { create :admin_user }

  before { sign_in admin_user }

  describe 'GET /admin/legal_aid_applications' do
    subject { get admin_legal_aid_applications_path }

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'displays applications' do
      subject
      legal_aid_applications.each do |application|
        expect(response.body).to include(application.application_ref)
      end
    end

    context 'when not authenticated' do
      before { sign_out admin_user }

      it 'redirects to log in' do
        subject
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end
  end

  describe 'DELETE /admin/legal_aid_applications/destroy_all' do
    subject { delete destroy_all_admin_legal_aid_applications_path }

    it 'deletes the legal_aid_applications' do
      expect { subject }.to change { LegalAidApplication.count }.by(-count)
    end

    it 'redirects back to index' do
      subject
      expect(response).to redirect_to(admin_legal_aid_applications_path)
    end

    context 'when not authenticated' do
      before { sign_out admin_user }

      it 'redirects to log in' do
        subject
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end

    context 'with a lot of associations' do
      let!(:another) { create :legal_aid_application, :with_everything }

      it 'gets deleted too' do
        expect { subject }.to change { LegalAidApplication.count }.to(0)
      end
    end
  end
end
