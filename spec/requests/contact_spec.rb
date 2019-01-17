require 'rails_helper'

RSpec.describe 'contact page', type: :request do
  describe 'GET /contact' do
    it 'returns renders successfully' do
      get contact_path
      expect(response).to have_http_status(:ok)
    end

    it 'display contact information' do
      get contact_path

      expect(response.body).to include(I18n.translate('contacts.show.h1-heading'))
      expect(response.body).to include(I18n.translate('contacts.show.page_header'))
      expect(response.body).to include(I18n.translate('contacts.show.case_inquiries.header'))
      expect(response.body).to include(I18n.translate('contacts.show.case_inquiries.phone.text'))
      expect(response.body).to include(I18n.translate('contacts.show.case_inquiries.phone.phone_number'))
      expect(response.body).to include(I18n.translate('contacts.show.technical_support.header'))
      expect(response.body).to include(I18n.translate('contacts.show.technical_support.email.text'))
      expect(response.body).to include(I18n.translate('contacts.show.technical_support.email.email_address'))
      expect(response.body).to include(I18n.translate('contacts.show.technical_support.phone.text'))
      expect(response.body).to include(I18n.translate('contacts.show.technical_support.phone.phone_number'))
    end
  end
end
