require "rails_helper"

RSpec.describe SamlIdpController do
  describe "POST /saml/auth" do
    let(:saml_request) { encode_saml_request }
    let(:password) { "password" }

    before do
      allow(Rails.configuration.x.laa_portal).to receive(:mock_saml).and_return(true)

      # Ensure that the service is not in maintenance mode why running the tests
      allow(Setting).to receive(:service_maintenance_mode?).and_return(false)
    end

    context "when the username and password is in config/initializers/mock_saml.rb" do
      let(:email) { "test1@example.com" }
      let(:username) { "test1" }

      context "when no Record for that provider exists in the database" do
        before { create(:provider, email:, username:) }

        it "renders the saml auth form with the encoded request" do
          post saml_auth_path, params: login_params
          expect(response).to be_successful
          expect(response.body).to include('<form action="http://www.example.com/providers/saml/auth?locale=en"')
          expect(response.body).to include('input type="hidden" name="SAMLResponse" id="SAMLResponse"')
        end
      end

      context "when no record exists for that user in database" do
        it "renders the saml auth form with the encoded request" do
          post saml_auth_path, params: login_params
          expect(response).to be_successful
          expect(response.body).to include("Incorrect email or password.")
        end
      end
    end

    context "when the user is not in config/initializers/mock_saml.rb" do
      let(:email) { "nobody@example.com" }
      let(:username) { "test1" }

      it "renders the saml auth form with the encoded request" do
        post saml_auth_path, params: login_params
        expect(response).to be_successful
        expect(response.body).to include("Incorrect email or password.")
      end
    end

    context "when the password was not as specified in config/initializers/mock_saml.rb" do
      let(:email) { "test1@example.com" }
      let(:username) { "test1" }
      let(:password) { "forgotten" }

      it "renders the saml auth form with the encoded request" do
        post saml_auth_path, params: login_params
        expect(response).to be_successful
        expect(response.body).to include("Incorrect email or password.")
      end
    end

    def encode_saml_request
      # call providers/saml/sign_in to get encoded saml request
      get "/providers/saml/sign_in", params: new_params
      expect(response).to have_http_status(:found)
      redirect_uri = URI(response.header["Location"])
      expect(redirect_uri.path).to eq "/saml/auth"
      request_string = redirect_uri.query.sub(/^SAMLRequest=/, "")
      CGI.unescape(request_string)
    end

    def new_params
      ActiveSupport::HashWithIndifferentAccess.new(
        {
          "locale" => "en",
          "controller" => "saml_sessions",
          "action" => "new",
        },
      )
    end

    def login_params
      ActiveSupport::HashWithIndifferentAccess.new(
        {
          "SAMLRequest" => saml_request,
          "email" => email,
          "password" => password,
          "commit" => "Sign in",
          "locale" => "en",
          "controller" => "saml_idp",
          "action" => "create",
        },
      )
    end
  end
end
