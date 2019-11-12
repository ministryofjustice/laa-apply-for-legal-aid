require 'rails_helper'

RSpec.describe 'contact page', type: :request do
  describe 'GET /contact' do
    it 'returns renders successfully' do
      get contact_path
      expect(response).to have_http_status(:ok)
    end

    it 'display contact information' do
      get contact_path

      expect(response.body).to include(I18n.t('contacts.show.case_enquiries.phone_number'))
      expect(response.body).to include(I18n.t('contacts.show.technical_support.email_address'))
    end
  end
end
