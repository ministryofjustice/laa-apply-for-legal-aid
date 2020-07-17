require 'rails_helper'

RSpec.describe Admin::RolesController, type: :request do
  let(:admin_user) { create :admin_user }
  before { sign_in admin_user }

  describe 'GET index' do
    subject { get admin_roles_permission_path }

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'displays correct heading' do
      subject
      expect(response.body).to include(I18n.t('admin.roles.permissions.show.heading_1'))
    end
  end
end
