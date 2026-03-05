require "rails_helper"

RSpec.describe Providers::Means::HMRCUnavailableInterruptsController do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:id/means/hmrc_unavailable_interrupt" do
    subject(:get_request) { get providers_legal_aid_application_means_hmrc_unavailable_interrupt_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_request
      end

      it "returns http success and the correct template" do
        expect(response).to have_http_status(:ok).and render_template("providers/means/hmrc_unavailable_interrupts/show")
      end

      it "shows the correct content" do
        expect(unescaped_response_body).to include("We cannot currently check your client's employment records automatically with HMRC")
      end
    end
  end
end
