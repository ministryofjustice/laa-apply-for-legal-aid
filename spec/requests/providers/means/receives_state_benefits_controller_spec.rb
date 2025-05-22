require "rails_helper"

RSpec.describe Providers::Means::ReceivesStateBenefitsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/means/receives_state_benefits" do
    subject(:make_request) { get providers_legal_aid_application_means_receives_state_benefits_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { make_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        make_request
      end

      it "returns an ok http status" do
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/means/receives_state_benefits" do
    subject(:make_request) { patch(providers_legal_aid_application_means_receives_state_benefits_path(legal_aid_application), params:) }

    let(:params) do
      { applicant: { receives_state_benefits: } }
    end
    let(:setup) { nil }

    before do
      setup
      login_as provider
      make_request
    end

    context "when the provider does not answer the question" do
      let(:receives_state_benefits) { "" }

      it "re-renders the page with an error" do
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Select yes if your client gets any benefits")
      end
    end

    context "when the provider says no benefits received" do
      let(:receives_state_benefits) { "false" }

      it "redirects to the next page" do
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when the provider says benefits are received" do
      let(:receives_state_benefits) { "true" }

      it "redirects to the next page" do
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when provider checking answers of citizen" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine, :checking_means_income) }

      context "and the provider says no benefits received" do
        let(:receives_state_benefits) { "false" }

        it "redirects to the next page" do
          expect(response).to have_http_status(:redirect)
        end
      end

      context "and more benefits are to be added" do
        let(:receives_state_benefits) { "true" }

        context "and another benefit exists" do
          let(:setup) do
            create(:regular_transaction,
                   transaction_type: create(:transaction_type, :benefits),
                   legal_aid_application:,
                   description: "Test state benefit",
                   owner_id: legal_aid_application.applicant.id,
                   owner_type: "Applicant")
          end

          it "redirects to the next page" do
            expect(response).to have_http_status(:redirect)
          end
        end

        context "and no other benefits exist" do
          it "redirects to the next page" do
            expect(response).to have_http_status(:redirect)
          end
        end
      end

      context "when form submitted with Save as draft button" do
        let(:params) do
          {
            applicant: { receives_state_benefits: "true" },
            draft_button: "Save and come back later",
          }
        end

        it "redirects to the list of applications" do
          expect(response).to redirect_to in_progress_providers_legal_aid_applications_path
        end
      end
    end
  end
end
