require 'rails_helper'

RSpec.describe Admin::Roles::PermissionsController, type: :request do
  let(:admin_user) { create :admin_user }
  let(:firm) { create :firm, :with_passported_permissions, name: 'Noodle, Legs & Co.' }
  let(:firm2) { create :firm, :with_non_passported_permissions, name: 'McKenzie, Brackman, Chaney and Kuzak' }
  before { sign_in admin_user }

  describe 'GET index' do
    subject { get admin_roles_path }

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'displays correct heading' do
      subject
      expect(response.body).to include(I18n.t('admin.roles.index.heading_1'))
    end

    it 'displays firms' do
      subject
      expect(unescaped_response_body).to include(firm.name)
      expect(unescaped_response_body).to include(firm2.name)
    end
  end
end
