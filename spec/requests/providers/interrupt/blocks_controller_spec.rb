require "rails_helper"

RSpec.describe Providers::Interrupt::BlocksController do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:id/blocked" do
    subject(:get_request) { get providers_legal_aid_application_block_path(legal_aid_application) }

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

      it "shows text to use CCMS" do
        expect(page)
          .to have_content("You cannot submit this application")
          .and have_content("This is because the application will be missing information after recent updates to the service.")
          .and have_content("You can (choose one of the following):")
          .and have_content("go back to your applications")
          .and have_content("Make a new application")
      end
    end
  end
end
