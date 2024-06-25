require "rails_helper"

RSpec.describe Providers::ProceedingsSCA::HeardTogethersController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings:, proceeding_count:) }
  let(:proceeding_count) { 2 }
  let(:explicit_proceedings) { %i[pb003 pb007] }
  let(:login_provider) { login_as legal_aid_application.provider }

  describe "GET /providers/applications/:id/heard_togethers" do
    subject(:get_request) { get providers_legal_aid_application_heard_togethers_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_provider
        get_request
      end

      context "when there is a core proceeding" do
        let(:core_sca) { legal_aid_application.proceedings.where(sca_type: "core").first.meaning }

        it "returns http success" do
          expect(response).to have_http_status(:ok)
          expect(unescaped_response_body).to include(I18n.t("providers.proceedings_sca.heard_togethers.show.page_heading.single", core_sca:))
        end
      end

      context "when there is more than one core proceeding" do
        let(:proceeding_count) { 3 }
        let(:explicit_proceedings) { %i[pb003 pb007 pb059] }

        it "returns http success" do
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(I18n.t("providers.proceedings_sca.heard_togethers.show.page_heading.multiple"))
        end
      end
    end
  end

  describe "PATCH providers/applications/:id/will_proceeding_be_heard_togethers" do
    subject(:patch_request) { patch providers_legal_aid_application_heard_togethers_path(legal_aid_application, params:) }

    before do
      login_provider
    end

    context "with form submitted using Save and continue button" do
      let(:params) do
        {
          binary_choice_form: {
            heard_together:,
          },
        }
      end

      before do
        patch_request
      end

      context "when yes is chosen" do
        let(:heard_together) { true }

        it "redirects to next page" do
          expect(response).to have_http_status(:redirect)
        end
      end

      context "when no is chosen" do
        let(:heard_together) { false }

        it "redirects to next page" do
          expect(response).to have_http_status(:redirect)
        end
      end

      context "when the provider does not provide a response" do
        let(:heard_together) { "" }

        it "renders the same page with an error message" do
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to include("Select yes if this proceeding will be heard together with any special children act core proceedings").twice
        end
      end
    end

    context "with form submitted using Save as draft button" do
      let(:params) { { draft_button: "Save and come back later" } }

      it "redirects provider to provider's applications page" do
        patch_request
        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end

      it "sets the application as draft" do
        expect { patch_request }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
      end
    end
  end
end
