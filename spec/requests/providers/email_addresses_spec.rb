require "rails_helper"

RSpec.describe "update client email address before application confirmation" do
  let(:application) { create(:legal_aid_application) }
  let(:application_id) { application.id }
  let(:provider) { application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/email_address" do
    subject(:get_request) { get "/providers/applications/#{application_id}/email_address" }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      it "returns http success" do
        get_request
        expect(response).to have_http_status(:ok)
      end

      it "displays the email label" do
        get_request
        expect(response.body).to include(I18n.t("shared.forms.applicant_form.email_label"))
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/email_address" do
    subject(:patch_request) { patch "/providers/applications/#{application_id}/email_address", params: }

    let(:application) { create(:legal_aid_application) }
    let(:provider) { application.provider }
    let(:params) do
      {
        applicant: {
          email: Faker::Internet.email,
        },
      }
    end

    context "when the provider is not authenticated" do
      before { patch_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "and the Continue button is pressed" do
        let(:submit_button) { { continue_button: "Continue" } }

        it "redirects to next page" do
          patch_request
          expect(response).to have_http_status(:redirect)
        end
      end
    end
  end
end
