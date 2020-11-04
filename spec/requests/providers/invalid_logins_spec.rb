require 'rails_helper'

RSpec.describe 'provider confirm office', type: :request do
  describe 'GET providers/invalid_login' do
    let(:email) { Rails.configuration.x.support_email_address }
    let(:provider) { create :provider, invalid_login_details: detail }
    before do
      login_as provider
      get providers_invalid_login_path
    end

    context 'no CCMS_Apply role' do
      let(:detail) { 'role' }
      it 'has the no permissions title' do
        expect(response.body).to include(HTMLEntities.new.encode(I18n.t('providers.invalid_logins.show.permission_title')))
      end
      it 'has the correct body' do
        expect(response.body).to include(I18n.t('providers.invalid_logins.show.role.html', team_email: email))
      end
    end

    context 'no user on CCMS Provider details API' do
      let(:detail) { 'api_details_user_not_found' }
      it 'has the no permissions title' do
        expect(response.body).to include(HTMLEntities.new.encode(I18n.t('providers.invalid_logins.show.permission_title')))
      end
      it 'has the correct body' do
        expect(response.body).to include(I18n.t('providers.invalid_logins.show.api_details_user_not_found.html', team_email: email))
      end
    end

    context 'API error' do
      let(:detail) { 'provider_details_api_error' }
      it 'has the no error title' do
        expect(response.body).to include(HTMLEntities.new.encode(I18n.t('providers.invalid_logins.show.error_title')))
      end
      it 'has the correct body' do
        expect(response.body).to include(I18n.t('providers.invalid_logins.show.provider_details_api_error.html', team_email: email))
      end
    end
  end
end
