require "rails_helper"

RSpec.describe Providers::DWP::ResultsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, :at_checking_applicant_details, :with_applicant_and_address) }

  describe "GET /providers/applications/:legal_aid_application_id/dwp/dwp-result" do
    subject(:get_request) { get providers_legal_aid_application_dwp_result_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as legal_aid_application.provider
        get_request
      end

      it "returns success" do
        expect(response).to be_successful
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/dwp/dwp-result" do
    subject(:patch_request) { patch providers_legal_aid_application_dwp_result_path(legal_aid_application), params: }

    let(:params) do
      {
        continue_button: "Continue",
      }
    end

    it "redirects to the next page" do
      patch_request
      expect(response).to have_http_status(:redirect)
    end
  end
end
