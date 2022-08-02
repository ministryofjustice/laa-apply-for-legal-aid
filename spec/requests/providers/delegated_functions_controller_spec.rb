require "rails_helper"

RSpec.describe "DelegatedFunctionsController", type: :request do
  let(:application) { create(:legal_aid_application, :with_proceedings) }
  let(:application_id) { application.id }
  let(:proceeding_id) { application.proceedings.first.id }
  let(:provider) { application.provider }

  before { allow(Setting).to receive(:enable_mini_loop?).and_return(true) } # TODO: Remove when the mini-loop feature flag is removed

  describe "GET /providers/applications/:legal_aid_application_id/delegated_functions/:proceeding_id" do
    subject(:get_df) { get "/providers/applications/#{application_id}/delegated_functions/#{proceeding_id}" }

    context "when the provider is not authenticated" do
      before { get_df }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_df
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays the email label" do
        expect(response.body).to include("Proceeding 1")
        expect(response.body).to include("Inherent jurisdiction high court injunction")
      end
    end
  end

  describe "POST /providers/applications/:legal_aid_application_id/delegated_functions/:proceeding_id" do
    subject(:post_df) { patch "/providers/applications/#{application_id}/delegated_functions/#{proceeding_id}", params: }

    let(:params) do
      {
        proceeding: {
          used_delegated_functions: false,
        },
      }
    end

    context "when the provider is not authenticated" do
      before { post_df }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "when the Continue button is pressed" do
        let(:submit_button) { { continue_button: "Continue" } }

        it "redirects to next page" do
          post_df
          expect(response.body).to redirect_to(providers_legal_aid_application_limitations_path(application_id))
        end
      end
    end
  end
end
