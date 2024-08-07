require "rails_helper"

RSpec.describe Providers::UseCCMSController do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:id/use_ccms" do
    subject(:get_request) { get providers_legal_aid_application_use_ccms_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "when state is not already use_ccms" do
        before { get_request }

        it "returns http success" do
          expect(response).to have_http_status(:ok)
        end

        it "shows text to use CCMS" do
          get_request
          expect(response.body).to include(I18n.t("shared.use_ccms.title_html"))
        end

        it "sets the state to use_ccms" do
          get_request
          expect(legal_aid_application.reload.state).to eq "use_ccms"
        end
      end

      context "when state already is use_ccms" do
        before { legal_aid_application.use_ccms!(:applicant_self_employed) }

        it "returns http success" do
          get_request
          expect(response).to have_http_status(:ok)
        end

        it "does not call :use_ccms!" do
          expect(legal_aid_application).not_to receive(:use_ccms!)
          get_request
        end

        it "leaves the ccms reason as :applicant_self_employed" do
          allow_any_instance_of(ActionDispatch::Request).to receive(:referer).and_return("http://www.example.com/providers")
          get_request
          expect(legal_aid_application.reload.ccms_reason).to eq "applicant_self_employed"
        end
      end
    end

    describe "ccms_reason" do
      before do
        login_as provider
        allow_any_instance_of(ActionDispatch::Request).to receive(:referer).and_return(referer)
      end

      context "when referrer is open_banking_consents page" do
        let(:referer) { providers_legal_aid_application_open_banking_consents_url(legal_aid_application) }

        it "sets the ccms reason to :no_provider_consent" do
          get providers_legal_aid_application_use_ccms_path(legal_aid_application)
          expect(legal_aid_application.reload.ccms_reason).to eq "no_online_banking"
        end
      end

      context "when referrer is another unknown page" do
        let(:referer) { "http://www.example.com/providers" }

        it "sets the ccms reason to :unknown" do
          get providers_legal_aid_application_use_ccms_path(legal_aid_application)
          expect(legal_aid_application.reload.ccms_reason).to eq "unknown"
        end
      end
    end
  end
end
