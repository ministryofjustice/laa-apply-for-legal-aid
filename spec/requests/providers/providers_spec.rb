require 'rails_helper'

RSpec.describe Providers::ProvidersController, type: :request do
  let(:provider) { create :provider }
  subject { get providers_provider_path }

  before do
    login_as provider
    subject
  end

  it 'renders' do
    expect(response).to have_http_status(:ok)
  end

  it 'displays the header' do
    expect(response.body).to include(I18n.t('providers.providers.show.page_title'))
  end

  it 'displays provider data' do
    expect(response.body).to include(provider.username)
  end

  context 'with unspaced roles' do
    let(:provider) { create :provider, roles: 'CWA,PUI' }
    it 'displays roles with spaces' do
      expect(response.body).to include('CWA, PUI')
    end
  end
end
