require "rails_helper"

RSpec.describe Providers::HomeAddress::DifferentAddressReasonsController do
  let(:legal_aid_application) { create(:legal_aid_application, applicant:) }
  let(:applicant) { create(:applicant, :with_address) }
  let(:provider) { legal_aid_application.provider }
  let(:login) { login_as provider }

  before { login }

  describe "GET /providers/applications/:legal_aid_application_id/home_address/why_addresses_differ" do
    subject(:get_request) do
      get providers_legal_aid_application_home_address_different_address_reason_path(legal_aid_application)
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
        text: "Why is your client's home address different to their correspondence address?",
      )
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/home_address/why_addresses_differ" do
    subject(:patch_request) { patch providers_legal_aid_application_home_address_different_address_reason_path(legal_aid_application), params: }

    context "when the provider is not authenticated" do
      let(:login) { nil }
      let(:params) { {} }

      before { patch_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when different home address is chosen" do
      let(:params) { { applicant: { no_fixed_residence: "false" } } }

      it "records the answer" do
        expect { patch_request }.to change { applicant.reload.no_fixed_residence }.from(nil).to(false)
      end

      it "redirects to the next page" do
        patch_request
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when client is homeless is chosen" do
      let(:params) { { applicant: { no_fixed_residence: "true" } } }

      it "records the answer" do
        expect { patch_request }.to change { applicant.reload.no_fixed_residence }.from(nil).to(true)
      end

      it "redirects to the next page" do
        patch_request
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when no answer chosen" do
      let(:params) { { applicant: { no_fixed_residence: "" }, continue_button: "Save and continue" } }

      it "stays on the page and displays validation error" do
        patch_request
        expect(response).to have_http_status(:ok)
        expect(page).to have_error_message("Select yes if your client has a home address")
      end
    end

    context "when form submitted using Save as draft button" do
      let(:params) { { applicant: { no_fixed_residence: "false" }, draft_button: "irrelevant" } }

      it "redirects provider to provider's applications page" do
        patch_request
        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end

      it "sets the application as draft" do
        expect { patch_request }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
      end

      it "records the answer" do
        expect { patch_request }.to change { applicant.reload.no_fixed_residence }.from(nil).to(false)
      end
    end
  end
end
