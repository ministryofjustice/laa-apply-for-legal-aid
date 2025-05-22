require "rails_helper"

RSpec.describe Providers::ProceedingsSCA::HeardAsAlternativesController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[pb003 pb007], proceeding_count: 2) }
  let(:provider) { legal_aid_application.provider }
  let(:proceeding) { legal_aid_application.proceedings.find_by(ccms_code: "PB007") }

  describe "GET /providers/applications/:id/will_proceeding_be_heard_as_an_alternative/:proceeding_id" do
    subject(:get_request) { get providers_legal_aid_application_heard_as_alternative_path(legal_aid_application, proceeding) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_request
      end

      context "when there is one core proceeding" do
        it "returns http success" do
          expect(response).to have_http_status(:ok)
          expect(response.body).to include("Will this proceeding be heard as an alternative to the &#39;Child assessment order&#39; proceeding?").once
          expect(response.body).to include("Will this proceeding be heard as an alternative to any of the special children act proceedings?").once
        end
      end

      context "when there is more than one core proceeding" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[pb003 pb007 pb059], proceeding_count: 3) }

        it "returns http success" do
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(I18n.t("providers.proceedings_sca.heard_as_alternatives.show.page_title.multiple"))
        end
      end
    end
  end

  describe "PATCH /providers/applications/:id/will_proceeding_be_heard_as_an_alternative/:proceeding_id" do
    subject(:patch_request) { patch providers_legal_aid_application_heard_as_alternative_path(legal_aid_application, proceeding, params:) }

    before do
      login_as provider
    end

    context "with form submitted using Save and continue button" do
      let(:params) do
        {
          binary_choice_form: {
            heard_as_alternative:,
          },
        }
      end

      before do
        patch_request
      end

      context "when yes is chosen" do
        let(:heard_as_alternative) { true }

        it "redirects to next page" do
          expect(response).to have_http_status(:redirect)
        end
      end

      context "when no is chosen" do
        let(:heard_as_alternative) { false }

        it "redirects to the interrupt page" do
          expect(response).to redirect_to providers_legal_aid_application_sca_interrupt_path(legal_aid_application, "heard_as_alternatives")
        end
      end

      context "when the provider does not provide a response" do
        let(:heard_as_alternative) { "" }

        it "renders the same page with an error message" do
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to include("Select yes if this proceeding will be heard as an alternative to any of the special children act proceedings").twice
        end
      end
    end

    context "with form submitted using Save as draft button" do
      let(:params) { { draft_button: "Save and come back later" } }

      it "redirects provider to provider's applications page" do
        patch_request
        expect(response).to redirect_to(in_progress_providers_legal_aid_applications_path)
      end

      it "sets the application as draft" do
        expect { patch_request }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
      end
    end
  end
end
