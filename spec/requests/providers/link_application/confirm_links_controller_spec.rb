require "rails_helper"

RSpec.describe Providers::LinkApplication::ConfirmLinksController do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:provider) { legal_aid_application.provider }
  let(:login) { login_as provider }

  before { login }

  describe "GET /providers/applications/:legal_aid_application_id/link_application/confirm_links" do
    subject(:get_request) do
      get providers_legal_aid_application_link_application_confirm_link_path(legal_aid_application)
    end

    before { get_request }

    context "when the provider is not authenticated" do
      let(:login) { nil }

      it_behaves_like "a provider not authenticated"
    end

    it "renders page with expected heading" do
      expect(response).to have_http_status(:ok)
      expect(page).to have_css(
        "h1",
        text: "Search results",
      )
    end
  end
end
