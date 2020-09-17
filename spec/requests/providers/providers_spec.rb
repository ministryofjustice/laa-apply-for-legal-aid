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
    expect(unescaped_response_body).to include(provider.name)
    expect(unescaped_response_body).to include(provider.username)
    expect(unescaped_response_body).to include(provider.email)
  end
end
