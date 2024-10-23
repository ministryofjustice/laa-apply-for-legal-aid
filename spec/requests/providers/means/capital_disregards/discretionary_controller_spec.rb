require "rails_helper"

RSpec.describe Providers::Means::CapitalDisregards::DiscretionaryController do
  let(:application) { create(:legal_aid_application, :with_applicant) }
  let(:provider) { application.provider }

  describe "GET providers/applications/:id/means/payments_to_review" do
    subject(:get_request) { get providers_legal_aid_application_means_capital_disregards_discretionary_path(application) }

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

      it "displays the show page" do
        expect(response.body).to include("Payments to be reviewed")
      end
    end
  end
end
