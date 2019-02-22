require 'rails_helper'

RSpec.describe Admin::LegalAidApplicationsController, type: :request do
  let!(:legal_aid_applications) { create_list :legal_aid_application, 3 }
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
    subject { delete destroy_all_admin_legal_aid_applications }
  end
end
