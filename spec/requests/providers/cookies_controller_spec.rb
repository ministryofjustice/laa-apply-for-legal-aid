require "rails_helper"

RSpec.describe Providers::CookiesController do
  let(:provider) { create(:provider) }

  describe "GET providers/cookies" do
    subject(:request) { get providers_cooky_path(provider) }

    context "when the provider is not authenticated" do
      before { request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        request
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays the correct content" do
        expect(unescaped_response_body).to include(I18n.t("providers.cookies.show.cookies_are_files"))
      end
    end
  end

  describe "PATCH providers/cookies" do
    subject(:request) { patch providers_cooky_path(provider), params: }

    let(:params)  { { provider: { cookies_enabled: } } }

    context "when the provider is authenticated" do
      before do
        login_as provider
        request
      end

      context "when nothing is selected" do
        let(:params) { {} }

        it "returns http_success" do
          expect(response).to have_http_status(:ok)
        end

        it "the response includes the error message" do
          expect(response.body).to include(I18n.t("activemodel.errors.models.provider.attributes.cookies_enabled.blank"))
        end
      end

      context "when no is selected" do
        let(:params) { { provider: { cookies_enabled: false } } }

        it "sets cookies enabled to false" do
          expect(provider.cookies_enabled).to be false
        end
      end

      context "when yes is selected" do
        let(:params) { { provider: { cookies_enabled: true } } }

        it "sets cookies enabled to true" do
          expect(provider.cookies_enabled).to be true
        end

        it "displays the success notification banner" do
          expect(response.body).to include(I18n.t("providers.cookies.show.success_message"))
        end
      end
    end
  end
end
