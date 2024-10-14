require "rails_helper"

RSpec.describe Providers::PreviousReferencesController do
  let(:application) { create(:legal_aid_application, applicant:) }
  let(:application_id) { application.id }
  let(:provider) { application.provider }
  let(:applicant) { create(:applicant) }

  describe "GET /providers/applications/:legal_aid_application_id/previous_references" do
    subject(:get_request) { get "/providers/applications/#{application_id}/previous_references" }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_request
      end

      it "shows the previous references page" do
        expect(response).to be_successful
        expect(unescaped_response_body).to include("Has your client applied for civil legal aid before?")
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/previous_references" do
    subject(:patch_request) do
      patch providers_legal_aid_application_previous_references_path(application), params:
    end

    let(:previous_references) { "300001234567" }
    let(:applied_previously) { "true" }
    let(:params) do
      {
        applicant: {
          previous_references:,
          applied_previously:,
        },
      }
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }
      let(:params) { {} }

      before { patch_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "when the provider indicates that they have not applied previously" do
        let(:previous_references) { nil }
        let(:applied_previously) { "false" }

        context "with form submitted using Save and continue button" do
          let(:submit_button) do
            {
              continue_button: "Save and continue",
            }
          end

          it "redirects to the next page" do
            patch_request
            expect(response).to have_http_status(:redirect)
          end

          it "records the answer" do
            expect { patch_request }.to change { applicant.reload.applied_previously }.from(nil).to(false)
          end
        end
      end

      context "when neither yes or no is chosen and save and continue is clicked" do
        let(:previous_references) { nil }
        let(:applied_previously) { nil }

        it "renders the form page displaying the errors" do
          patch_request

          expect(unescaped_response_body).to include("Select yes if your client has applied for civil legal aid before")
          expect(response).to have_http_status(:ok)
        end
      end

      context "when form submitted using Save as draft button" do
        let(:params) { { applicant: { applied_previously: "false" }, draft_button: "irrelevant" } }

        it "redirects provider to provider's applications page" do
          patch_request
          expect(response).to redirect_to(submitted_providers_legal_aid_applications_path)
        end

        it "sets the application as draft" do
          expect { patch_request }.to change { application.reload.draft? }.from(false).to(true)
        end

        it "records the answer" do
          expect { patch_request }.to change { applicant.reload.applied_previously }.from(nil).to(false)
        end
      end
    end
  end
end
