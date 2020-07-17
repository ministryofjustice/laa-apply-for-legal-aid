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

    it 'shows the correct permissions are checked/unchecked' do
      subject
      expect(response.body).to include('application.passported._')
      expect(response.body).not_to include('application.non_passported._')
    end
  end

  describe 'PATCH /index' do
    subject { patch admin_roles_permission_path(firm.id), params: params.merge(submit_button) }
    let(:submit_button) { { continue_button: 'Save and Continue' } }
    let(:params) { {} }

    context 'Save and Continue button pressed with no changes' do
      it 'redirects to next page' do
        expect(subject).to redirect_to(admin_settings_path)
      end
    end

    context 'Save and Continue button pressed with new permission changes' do
      subject { patch admin_roles_permission_path(firm.id), params: params.merge(submit_button) }
      let(:submit_button) { { continue_button: 'Save and Continue' } }
      let(:params) do
        {
            firm:  {
              :permission_ids => ["87752110-c00e-4372-8be5-e1d10755c622", "19a8d08c-5f91-4cd0-b8ab-8332a5162b1f",]
            }
        }
      end

      it 'saves new permissions and redirects to next page' do
        # ap 11111
        # ap firm.permissions.count
        # subject
        # ap 22222
        # ap firm.permissions
        # ap firm.permissions.count
        expect{subject}.to change{firm.permissions.count}.by(1)
      end
    end
  end
end

