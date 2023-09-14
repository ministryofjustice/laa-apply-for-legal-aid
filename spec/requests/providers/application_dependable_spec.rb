require "rails_helper"

RSpec.describe "Providers::ApplicationDependable", :vcr do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:provider) { legal_aid_application.provider }

  describe "GET an action" do
    subject(:get_request) { get providers_legal_aid_application_proceedings_types_path(legal_aid_application) }

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

      it "records the current controller name" do
        expect(legal_aid_application.reload.provider_step).to eq("proceedings_types")
      end
    end
  end
end
