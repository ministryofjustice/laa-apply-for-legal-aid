require "rails_helper"

RSpec.describe Providers::LinkApplication::MakeLinksController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/link_application/make_link" do
    subject(:get_request) { get providers_legal_aid_application_link_application_make_link_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_request
      end

      it "shows the link application invitation page" do
        expect(response).to be_successful
        expect(unescaped_response_body).to include("Do you want to link this application with another one?")
      end
    end
  end
end
