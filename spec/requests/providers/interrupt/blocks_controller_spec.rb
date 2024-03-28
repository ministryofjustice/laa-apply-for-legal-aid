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
        get_request
        expect(response.body).to include("You cannot submit this application")
      end
    end
  end
end
