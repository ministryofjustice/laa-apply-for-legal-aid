require "rails_helper"

RSpec.describe Providers::Partners::AboutFinancialMeansController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_partner) }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:id/partners/about_financial_means" do
    subject(:get_request) { get providers_legal_aid_application_partners_about_financial_means_path(legal_aid_application) }

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
        expect(unescaped_response_body).to include(I18n.t("providers.partners.about_financial_means.show.h1-heading"))
      end
    end
  end

  describe "PATCH /providers/applications/:id/partners/about_financial_means" do
    subject(:get_request) { patch providers_legal_aid_application_partners_about_financial_means_path(legal_aid_application) }

    before do
      login_as provider
      get_request
    end

    it "redirects to next page" do
      expect(response).to have_http_status(:redirect)
    end
  end
end
