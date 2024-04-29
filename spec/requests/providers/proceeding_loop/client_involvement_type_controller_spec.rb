require "rails_helper"

RSpec.describe "ClientInvolvementTypeController", :vcr do
  let(:application) { create(:legal_aid_application, :with_proceedings) }
  let(:application_id) { application.id }
  let(:proceeding_id) { application.proceedings.first.id }
  let(:provider) { application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/client_involvement_type/:proceeding_id" do
    subject(:get_cit) { get "/providers/applications/#{application_id}/client_involvement_type/#{proceeding_id}" }

    context "when the provider is not authenticated" do
      before { get_cit }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_cit
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays the heading" do
        expect(response.body).to include("Proceeding 1")
        expect(response.body).to include("Inherent jurisdiction high court injunction")
        expect(unescaped_response_body).to include("What is your client's role in this proceeding?")
      end
    end
  end

  describe "POST /providers/applications/:legal_aid_application_id/client_involvement_type/:proceeding_id" do
    subject(:post_cit) { patch "/providers/applications/#{application_id}/client_involvement_type/#{proceeding_id}", params: }

    let(:params) do
      {
        proceeding: {
          client_involvement_type: "A",
        },
      }
    end

    context "when the provider is not authenticated" do
      before { post_cit }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "when the Continue button is pressed" do
        let(:submit_button) { { continue_button: "Continue" } }

        it "redirects to next page" do
          post_cit
          expect(response).to have_http_status(:redirect)
        end
      end

      context "when form submitted with Save as draft button" do
        let(:params) do
          {
            draft_button: "Save and come back later",
          }
        end

        it "redirects to the list of applications" do
          post_cit
          expect(response.body).to redirect_to providers_legal_aid_applications_path
        end
      end
    end
  end
end
