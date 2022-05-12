require "rails_helper"

RSpec.describe "provider cookies", type: :request do
  let(:provider) { create :provider }

  describe "GET providers/cookies" do
    subject { get providers_cooky_path }

    context "when the provider is not authenticated" do
      before { subject }

      it_behaves_like "a provider not authenticated"
    end

    # context "invalid login" do
    #   let(:provider) { create :provider, invalid_login_details: "role" }
    #
    #   before do
    #     login_as provider
    #     subject
    #   end
    #
    #   it "redirects to the invalid login page" do
    #     expect(response).to redirect_to providers_invalid_login_path
    #   end
    # end

    context "when the provider is authenticated" do
      before do
        login_as provider
        subject
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays the correct content" do
        expect(unescaped_response_body).to include(t('providers.cookies.show.cookies_are_files'))
      end

      # context "provider has not selected their cookie preferences" do
      #   let(:provider) { create :provider, cookies_enabled: nil }
      #
      #   it "redirects to the cookies page" do
      #     expect(response).to redirect_to providers_cooky_path
      #   end
      # end
    end
  end

  describe "PATCH providers/cookies" do
    subject { patch providers_cooky_path, params: }

    let(:params) { { cookies_enabled_form: { cookies_enabled: "true" } } }

    context "when the provider is authenticated" do
      before do
        login_as provider
        subject
      end

      it "redirects to the cookies page" do
        expect(response).to redirect_to providers_cooky_path
      end

      context "invalid params - nothing specified" do
        let(:params) { {} }

        it "returns http_success" do
          expect(response).to have_http_status(:ok)
        end

        it "the response includes the error message" do
          expect(response.body).to include(I18n.t("providers.confirm_offices.show.error"))
        end
      end

      context "no is selected" do
        let(:params) { { cookies_enabled_form: { cookies_enabled: "false" } } }

        it "redirects to the office select page" do
          expect(response).to redirect_to providers_select_office_path
        end

        it "clears the existing office" do
          expect(provider.reload.selected_office).to be_nil
        end
      end
    end
  end
end
