require 'rails_helper'

RSpec.describe Admin::RolesController, type: :request do
  let(:admin_user) { create :admin_user }
  let!(:firm) { create :firm, name: 'Noodle, Legs & Co.' }
  let!(:firm2) { create :firm, name: 'McKenzie, Brackman, Chaney and Kuzak' }
  let!(:firm3) { create :firm, name: 'McKenzie, Crook, and Gervais' }
  let!(:firm4) { create :firm, name: 'Nelson and Murdock' }
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
      expect(response.body).to include(firm2.name)
    end

    context 'when the search field is used' do
      it ' returns the relevant firm' do
        expect(Firm.search('Nelson')).to eq([firm4])
      end

      it 'returns all relevant firms' do
        expect(Firm.search('McKenzie')).to match_array([firm2, firm3])
      end
    end
  end
end
