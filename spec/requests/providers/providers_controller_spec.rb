require "rails_helper"

RSpec.describe Providers::ProvidersController do
  let(:provider) { create(:provider) }

  before do
    login_as provider
    get providers_provider_path
  end

  it "renders" do
    expect(response).to have_http_status(:ok)
  end

  it "displays the header" do
    expect(response.body).to include(I18n.t("providers.providers.show.page_title"))
  end

  it "displays provider data" do
    expect(unescaped_response_body).to include(provider.name)
    expect(unescaped_response_body).to include(provider.email)
  end
end
