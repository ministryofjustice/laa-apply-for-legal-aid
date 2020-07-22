require 'rails_helper'

RSpec.describe Admin::Roles::PermissionsController, type: :request do
  let(:admin_user) { create :admin_user }
  let!(:firm) { create :firm, :with_passported_permissions, name: 'McKenzie, Brackman, Chaney and Kuzak' }
  before { sign_in admin_user }

  describe 'GET index' do
    subject { get admin_roles_permission_path(firm.id) }

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'displays correct heading' do
      subject
      expect(response.body).to include(I18n.t('admin.roles.permissions.show.heading_1', firm_name: firm.name))
    end

    it 'shows the correct permissions' do
      subject
      expect(response.body).to include('application.passported._')
      expect(response.body).not_to include('application.non_passported._')
    end
  end

  describe 'PATCH /index' do
    subject { patch admin_roles_permission_path(firm.id), params: params.merge }
    let(:params) { {} }

    context 'Save and Continue button pressed with no changes' do
      it 'redirects to main admin page' do
        expect(subject).to redirect_to(admin_root_path)
      end
    end

    context 'Save and Continue button pressed with new permission changes' do
      let!(:permission2) { create :permission, :non_passported }
      let!(:params) do
        {
          firm: {
            permission_ids: [permission2.id, firm.permissions.first.id]
          }
        }
      end

      it 'saves the new permission' do
        expect { subject }.to change { firm.permissions.count }.by(1)
      end
    end
  end
end
