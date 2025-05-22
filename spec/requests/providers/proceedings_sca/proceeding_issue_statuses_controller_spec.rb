require "rails_helper"

RSpec.describe Providers::ProceedingsSCA::ProceedingIssueStatusesController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings) }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:id/proceeding_issue_status" do
    subject(:get_request) { get providers_legal_aid_application_proceeding_issue_statuses_path(legal_aid_application) }

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
        expect(response.body).to include(I18n.t("providers.proceedings_sca.proceeding_issue_statuses.show.page_title"))
      end
    end
  end

  describe "PATCH /providers/applications/:id/proceeding_issue_status" do
    subject(:get_request) { patch providers_legal_aid_application_proceeding_issue_statuses_path(legal_aid_application, params:) }

    before do
      login_as provider
    end

    context "with form submitted using Save and continue button" do
      let(:params) do
        {
          binary_choice_form: {
            proceeding_issue_status:,
          },
        }
      end

      before do
        get_request
      end

      context "when yes is chosen" do
        let(:proceeding_issue_status) { true }

        it "redirects to next page" do
          expect(response).to have_http_status(:redirect)
        end
      end

      context "when no is chosen" do
        let(:proceeding_issue_status) { false }

        it "redirects to the interrupt page" do
          expect(response).to redirect_to providers_legal_aid_application_sca_interrupt_path(legal_aid_application, "proceeding_issue_status")
        end
      end

      context "when the provider does not provide a response" do
        let(:proceeding_issue_status) { "" }

        it "renders the same page with an error message" do
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to include("Select yes if this proceeding has been issued").twice
        end
      end
    end

    context "with form submitted using Save as draft button" do
      let(:params) { { draft_button: "Save and come back later" } }

      it "redirects provider to provider's applications page" do
        get_request
        expect(response).to redirect_to(in_progress_providers_legal_aid_applications_path)
      end

      it "sets the application as draft" do
        expect { get_request }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
      end
    end
  end
end
