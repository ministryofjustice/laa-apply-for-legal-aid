require "rails_helper"

RSpec.describe Providers::ProceedingsSCA::SupervisionOrdersController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[da002]) }
  let(:login_provider) { login_as legal_aid_application.provider }

  describe "GET /providers/applications/:id/supervision_orders" do
    subject(:get_request) { get providers_legal_aid_application_supervision_orders_path(legal_aid_application) }

    before do
      login_provider
      get_request
    end

    it "renders show with ok status" do
      expect(response).to have_http_status(:ok).and render_template("providers/proceedings_sca/supervision_orders/show")
    end

    context "when not authenticated" do
      let(:login_provider) { nil }

      it_behaves_like "a provider not authenticated"
    end

    context "when authenticated as a different provider" do
      let(:login_provider) { login_as create(:provider) }

      it_behaves_like "an authenticated provider from a different firm"
    end
  end

  describe "PATCH /providers/applications/:id/supervision_orders" do
    subject(:patch_request) do
      patch(providers_legal_aid_application_supervision_orders_path(legal_aid_application, params:))
    end

    let(:params) do
      {
        binary_choice_form: {
          change_supervision_order:,
        },
      }
    end
    let(:skip?) { false }

    before do
      login_provider
      patch_request unless skip?
    end

    context "when the provider responds yes" do
      let(:change_supervision_order) { "true" }

      it "redirects to the next page" do
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(providers_legal_aid_application_sca_interrupt_path(legal_aid_application, "supervision"))
      end
    end

    context "when the provider responds no" do
      let(:change_supervision_order) { "false" }

      it "redirects to the next page" do
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when the provider does not provide a response" do
      let(:change_supervision_order) { "" }

      it "renders the same page with an error message" do
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Select yes if the application is to vary, discharge or extend a supervision order").twice
      end
    end

    context "with form submitted using Save as draft button" do
      let(:skip?) { true }
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
