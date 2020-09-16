require 'rails_helper'

module Admin
  RSpec.describe FirmsController, type: :request do
    let(:admin_user) { create :admin_user }
    let(:permission) { create :permission }
    let!(:firms) { create_list :firm, 3 }

    before do
      firms.first.update!({ permission_ids: [permission.id] })
      sign_in admin_user
    end

    describe 'GET admin/firms' do
      before { get admin_firms_path }

      it 'renders successfully' do
        expect(response).to have_http_status(:ok)
      end

      it 'displays page heading' do
        expect(response.body).to include('List of firms')
      end

      it 'the displays the name of every firm' do
        response_body = CGI.unescapeHTML(response.body)
        expect(response_body).to include(firms[0].name)
        expect(response_body).to include(firms[1].name)
        expect(response_body).to include(firms[2].name)
      end

      it 'displays firm permissions' do
        response_body = CGI.unescapeHTML(response.body)
        expect(response_body).to include(permission.description)
      end
    end
  end
end
