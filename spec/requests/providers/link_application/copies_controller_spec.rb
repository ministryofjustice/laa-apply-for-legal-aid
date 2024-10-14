require "rails_helper"

RSpec.describe Providers::LinkApplication::CopiesController do
  let(:lead_application) { create(:legal_aid_application) }
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:provider) { legal_aid_application.provider }

  before { create(:linked_application, lead_application:, target_application: lead_application, associated_application: legal_aid_application) }

  describe "GET /providers/applications/:legal_aid_application_id/link_application/copy" do
    subject(:get_request) { get providers_legal_aid_application_link_application_copy_path(legal_aid_application) }

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
        expect(unescaped_response_body).to match(/Do you want to copy the proceedings and merits from L-.{3}-.{3} to this one\?/)
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/link_application/copy" do
    subject(:patch_request) { patch providers_legal_aid_application_link_application_copy_path(legal_aid_application), params: }

    let(:params) do
      {
        legal_aid_application: {
          copy_case:,
        },
      }
    end
    let(:copy_case) { nil }

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "when the form is saved" do
        context "and no radio button is checked" do
          it "re-renders the form with the validation errors" do
            patch_request
            expect(response).to have_http_status(:ok)
            expect(unescaped_response_body).to include("Select yes if you want to copy the proceedings and merits information from the application you linked to")
          end
        end

        context "when a value is chosen" do
          let(:copy_case) { "true" }

          it "redirects to the next page in the flow" do
            patch_request
            expect(response).to have_http_status(:redirect)
          end

          context "and it is yes" do
            it "sets a success flash message" do
              patch_request
              expect(flash[:hash][:heading_text]).to match(/You have copied the proceedings and merits information from L-.{3}-.{3} to this one./)
            end
          end

          context "and it is no" do
            let(:copy_case) { "false" }

            it "does not set a success flash message" do
              patch_request
              expect(flash).to be_empty
            end
          end
        end
      end

      context "when form submitted with Save as draft button" do
        let(:params) do
          {
            legal_aid_application: {
              copy_case: true,
            },
            draft_button: "Save and come back later",
          }
        end

        it "redirects to the list of applications" do
          patch_request
          expect(response).to redirect_to submitted_providers_legal_aid_applications_path
        end

        it "sets the application as draft" do
          expect { patch_request }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
        end

        it "records the value selected" do
          expect { patch_request }.to change { legal_aid_application.reload.copy_case }.from(nil).to(true)
        end
      end
    end
  end
end
