require "rails_helper"

RSpec.describe Providers::CapitalIntroductionsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_passported_state_machine, :checking_applicant_details) }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:id/capital_introduction" do
    subject(:request) { get providers_legal_aid_application_capital_introduction_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        request
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end
    end

    context "when the application is passported" do
      before do
        login_as provider
        request
      end

      context "when the state is checking_applicant_details" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_passported_state_machine, :checking_applicant_details) }

        it "returns http success" do
          expect(response).to have_http_status(:ok)
        end

        it "changes the state to provider_entering_means" do
          expect(legal_aid_application.reload.state).to eq "provider_entering_means"
        end
      end

      context "when the state is applicant_details_checked" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_passported_state_machine, :at_applicant_details_checked) }

        it "returns http success" do
          expect(response).to have_http_status(:ok)
        end

        it "changes the state to provider_entering_means" do
          expect(legal_aid_application.reload.state).to eq "provider_entering_means"
        end
      end
    end

    context "when the application is non-passported" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine, :provider_assessing_means) }

      before do
        login_as provider
        request
      end

      context "and the application has no partner" do
        it "returns http success" do
          expect(response).to have_http_status(:ok)
        end

        it "displays the correct content" do
          expect(response.body).to include(I18n.t("providers.capital_introductions.show.h1-heading", individual: "your client"))
        end
      end

      context "and the application has a partner" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_partner, :with_non_passported_state_machine, :provider_assessing_means) }

        it "returns http success" do
          expect(response).to have_http_status(:ok)
        end

        it "displays the correct content" do
          expect(response.body).to include(I18n.t("providers.capital_introductions.show.h1-heading", individual: "your client and their partner"))
        end
      end
    end
  end

  describe "PATCH /providers/applications/:id/capital_introduction" do
    subject(:request) { patch providers_legal_aid_application_capital_introduction_path(legal_aid_application) }

    before do
      login_as provider
    end

    it "redirects to the next page" do
      request
      expect(response).to have_http_status(:redirect)
    end
  end
end
