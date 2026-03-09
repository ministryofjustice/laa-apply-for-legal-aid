require "rails_helper"

RSpec.describe Providers::Partners::EmployedButNoHMRCDataInterruptsController do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:id/partners/employed_but_no_hmrc_data_interrupt" do
    subject(:get_request) { get providers_legal_aid_application_partners_employed_but_no_hmrc_data_interrupt_path(legal_aid_application) }

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
        expect(response).to have_http_status(:ok).and render_template("providers/partners/employed_but_no_hmrc_data_interrupts/show")
      end

      it "shows the correct content" do
        expect(unescaped_response_body).to include("HMRC has no record of the partner's employment in the last 3 months")
      end

      it "shows the correct link to the next step" do
        expect(unescaped_response_body).to include(providers_legal_aid_application_partners_full_employment_details_path)
      end
    end
  end
end
