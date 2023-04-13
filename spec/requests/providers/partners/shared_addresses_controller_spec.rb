require "rails_helper"

RSpec.describe Providers::Partners::SharedAddressesController do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/shared_address" do
    subject(:get_shared_address) { get providers_legal_aid_application_shared_address_path(legal_aid_application) }

    before do
      login_as provider
      get_shared_address
    end

    it "renders page with expected heading" do
      expect(response).to have_http_status(:ok)
      expect(page).to have_css(
        "h1",
        text: "Is the partner's correspondence address the same as your client's?",
      )
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/shared_address" do
    subject(:patch_shared_address) { patch providers_legal_aid_application_shared_address_path(legal_aid_application), params: }

    let(:params) do
      {
        partner: {
          shared_address_with_client:,
        },
      }.merge(submit_button)
    end
    let(:shared_address_with_client) { "true" }
    let(:submit_button) { { continue_button: "Continue" } }

    context "when the provider is not authenticated" do
      before { patch_shared_address }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before { login_as provider }

      context "when the params incomplete" do
        let(:shared_address_with_client) { "" }

        it "re-renders the page with the expected error" do
          patch_shared_address
          expect(response.body).to include("Select yes if the partner&#39;s correspondence address is the same as your client&#39;s")
        end
      end

      context "when the params are valid" do
        context "and the answer is yes" do
          let(:shared_address_with_client) { "true" }

          it "directs to the next page" do
            patch_shared_address
            expect(response).to redirect_to providers_legal_aid_application_check_provider_answers_path(legal_aid_application)
          end
        end

        context "and the answer is no" do
          let(:shared_address_with_client) { "false" }

          it "directs to the next page" do
            patch_shared_address
            expect(response).to redirect_to providers_legal_aid_application_partners_address_lookup_path(legal_aid_application)
          end
        end
      end
    end
  end
end
