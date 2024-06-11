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

  describe "PATCH /providers/applications/:id/about_financial_means" do
    subject(:get_request) { patch providers_legal_aid_application_about_financial_means_path(legal_aid_application) }

    before do
      login_as provider
      get_request
    end

    it "redirects to next page" do
      expect(response).to have_http_status(:redirect)
    end
  end
end
