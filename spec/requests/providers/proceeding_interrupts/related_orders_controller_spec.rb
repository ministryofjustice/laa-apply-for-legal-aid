require "rails_helper"

RSpec.describe Providers::ProceedingInterrupts::RelatedOrdersController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[pbm16]) }
  let(:provider) { legal_aid_application.provider }
  let(:proceeding) { legal_aid_application.proceedings.find_by(ccms_code: "PBM16") }

  describe "GET /providers/applications/:id/related_orders/:proceeding_id" do
    subject(:get_request) { get providers_legal_aid_application_related_order_path(legal_aid_application, proceeding) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_request
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "PATCH /providers/applications/:id/related_orders/:proceeding_id" do
    subject(:patch_request) { patch providers_legal_aid_application_related_order_path(legal_aid_application, proceeding, params:) }

    let(:params) do
      {
        proceeding: {
          none_selected:,
          related_orders:,
        },
      }
    end
    let(:none_selected) { "" }
    let(:related_orders) { [""] }

    before do
      login_as provider

      patch_request
    end

    context "with form submitted using Save and continue button" do
      context "when no choice is made" do
        it "renders the same page with an error message" do
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to include("Select which orders the proceeding relates to").twice
        end
      end

      context "when the user selects none of these" do
        let(:none_selected) { "true" }

        it "redirects to the interrupt page" do
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to providers_legal_aid_application_sca_interrupt_path(legal_aid_application, "plf_none_selected")
        end
      end

      context "when the user selects one checkbox" do
        let(:related_orders) { %w[placement] }

        it "redirects to the next page" do
          expect(response).to have_http_status(:redirect)
        end
      end

      context "when the user selects multiple checkboxes" do
        let(:related_orders) { %w[placement parenting] }

        it "redirects to the next page" do
          expect(response).to have_http_status(:redirect)
        end
      end
    end

    context "when the form is submitted with save as draft" do
      let(:params) do
        {
          proceeding: {
            none_selected:,
            related_orders:,
          },
          draft_button: "Save and come back later",
        }
      end

      context "when no choice is made" do
        it "redirects to the home page" do
          expect(response).to redirect_to(submitted_providers_legal_aid_applications_path)
        end
      end

      context "when the user selects none of these" do
        let(:none_selected) { "true" }

        it "redirects to the home page" do
          expect(response).to redirect_to(submitted_providers_legal_aid_applications_path)
        end
      end

      context "when the user selects one checkbox" do
        let(:related_orders) { %w[placement] }

        it "redirects to the home page" do
          expect(response).to redirect_to(submitted_providers_legal_aid_applications_path)
        end
      end

      context "when the user selects multiple checkboxes" do
        let(:related_orders) { %w[placement parenting] }

        it "redirects to the home page" do
          expect(response).to redirect_to(submitted_providers_legal_aid_applications_path)
        end
      end
    end
  end
end
