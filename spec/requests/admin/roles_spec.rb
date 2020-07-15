require 'rails_helper'

RSpec.describe Admin::RolesController, type: :request do
  let(:admin_user) { create :admin_user }
  let(:firm) { create :firm, name: 'Shotgun, Bobble & Dribble' }
  let(:firm2) { create :firm, name: 'Noodle, Legs & Co.' }
  let(:firm3) { create :firm }
  before { sign_in admin_user }

  describe 'GET index' do
    subject { get admin_roles_path }

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'displays correct heading' do
      subject
      expect(response.body).to include('Search for the Provider firm name')
    end

    it 'displays correct number of firms' do
      subject
      expect(response.body).to include('Shotgun, Bobble & Dribble')
      expect(response.body).to include(:firm.name)
    end
  end
end
