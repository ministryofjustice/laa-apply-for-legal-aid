require "rails_helper"

RSpec.describe Providers::LinkApplication::ConfirmLinksController do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:lead_application) { create(:legal_aid_application) }
  let(:provider) { legal_aid_application.provider }

  before { LinkedApplication.create!(lead_application_id: lead_application.id, associated_application_id: legal_aid_application.id, link_type_code: "FC_LEAD") }

  describe "GET /providers/applications/:legal_aid_application_id/link_application/confirm_link" do
    subject(:get_request) do
      get providers_legal_aid_application_link_application_confirm_link_path(legal_aid_application)
    end

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_request
      end

      it "renders page with expected heading" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_css(
          "h1",
          text: "Search result",
        )
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/link_application/confirm_link" do
    subject(:patch_request) { patch providers_legal_aid_application_link_application_confirm_link_path(legal_aid_application), params: }

    let(:params) do
      {
        legal_aid_application: {
          link_case:,
        },
      }
    end
    let(:link_case) { "true" }

    context "when the provider is not authenticated" do
      before { patch_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before { login_as provider }

      context "when the Continue button is pressed" do
        context "when Yes is chosen" do
          it "does not not destroy the linked application" do
            patch_request
            expect(legal_aid_application.reload.lead_application).to eq lead_application
          end

          it "sets link_case to true" do
            patch_request
            expect(legal_aid_application.reload.link_case).to be true
          end
        end

        context "when No, carry on without linking is chosen" do
          let(:link_case) { "false" }

          it "destroys the linked application" do
            patch_request
            expect(legal_aid_application.reload.lead_application).to be_nil
          end

          it "sets link_case to false" do
            patch_request
            expect(legal_aid_application.reload.link_case).to be false
          end
        end

        context "when No, I want to link to a different case is chosen" do
          let(:link_case) { "No" }

          it "does not not destroy the linked application" do
            patch_request
            expect(legal_aid_application.reload.lead_application).to eq lead_application
          end

          it "sets link_case to false" do
            patch_request
            expect(legal_aid_application.reload.link_case).to be_nil
          end
        end

        context "when form submitted with Save as draft button" do
          let(:params) do
            {
              draft_button: "Save and come back later",
            }
          end

          it "redirects to the list of applications" do
            patch_request
            expect(response.body).to redirect_to providers_legal_aid_applications_path
          end

          it "sets the application as draft" do
            expect { patch_request }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
          end
        end
      end
    end
  end
end
