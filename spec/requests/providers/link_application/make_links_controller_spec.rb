require "rails_helper"

RSpec.describe Providers::LinkApplication::MakeLinksController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/link_application/make_link" do
    subject(:get_request) { get providers_legal_aid_application_link_application_make_link_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_request
      end

      it "shows the link application invitation page" do
        expect(response).to be_successful
        expect(unescaped_response_body).to include("Do you want to link this application with another one?")
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/link_application/make_link" do
    subject(:patch_request) { patch providers_legal_aid_application_link_application_make_link_path(legal_aid_application), params: }

    let(:params) do
      {
        linked_application: {
          link_type_code:,
        },
      }
    end
    let(:link_type_code) { "FC_LEAD" }

    context "when the provider is not authenticated" do
      before { patch_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "when the Continue button is pressed" do
        context "when a link type is chosen" do
          it "redirects to next page" do
            patch_request
            # TODO: This will change when ap-4826 is complete
            expect(response).to redirect_to(providers_legal_aid_application_proceedings_types_path)
          end

          it "creates a new lead linked application" do
            expect { patch_request }.to change(LinkedApplication, :count).by(1)
          end

          it "sets the correct link type" do
            patch_request
            expect(legal_aid_application.reload.lead_linked_application.link_type_code).to eq "FC_LEAD"
          end
        end

        context "when no is chosen" do
          let(:link_type_code) { "false" }

          it "redirects to next page" do
            patch_request
            expect(response).to redirect_to(providers_legal_aid_application_proceedings_types_path)
          end

          it "does not create a new lead linked application" do
            expect { patch_request }.not_to change(LinkedApplication, :count)
          end
        end

        context "with a nil link_type_code" do
          let(:link_type_code) { nil }

          it "re-renders the form with the validation errors" do
            patch_request
            expect(unescaped_response_body).to include("Select if you want to link this application with another one")
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
