require "rails_helper"

RSpec.describe Providers::Partners::DetailsController do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:provider) { legal_aid_application.provider }

  before { login_as provider }

  describe "GET /providers/applications/:legal_aid_application_id/partners_details" do
    subject! do
      get providers_legal_aid_application_partners_details_path(legal_aid_application)
    end

    it "renders page with expected heading" do
      expect(response).to have_http_status(:ok)
      expect(page).to have_css(
        "h1",
        text: "Enter the partner's details",
      )
    end
  end

  describe "PATCH /providers/applications/:application_id/partners_details" do
    subject(:patch_partners_details) { patch providers_legal_aid_application_partners_details_path(legal_aid_application), params: }

    let(:submit_button) { {} }
    let(:params) do
      {
        partner: {
          first_name:,
          last_name: "Doe",
          "date_of_birth(1i)": "1981",
          "date_of_birth(2i)": "07",
          "date_of_birth(3i)": "11",
          has_national_insurance_number: "true",
          national_insurance_number: "AB123456A",
        },
      }.merge(submit_button)
    end
    let(:first_name) { "John" }

    it "creates a partner record" do
      expect { patch_partners_details }.to change(Partner, :count).by(1)

      expect(legal_aid_application.reload.partner).to have_attributes(
        first_name: "John",
        last_name: "Doe",
        date_of_birth: Date.new(1981, 7, 11),
        national_insurance_number: "AB123456A",
      )
    end

    it "redirects to next page" do
      patch_partners_details
      expect(response).to have_http_status(:redirect)
    end

    context "when parameters are missing" do
      let(:first_name) { "" }

      it "displays errors" do
        patch_partners_details
        expect(response.body).to include("govuk-error-summary")
      end

      it "does not create a partner" do
        expect { patch_partners_details }.not_to change(Partner, :count)
      end
    end

    context "with form submitted using Save as draft button" do
      let(:submit_button) { { draft_button: "Save as draft" } }

      it "redirects provider to provider's applications page" do
        patch_partners_details
        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end

      it "creates a partner with the expected values" do
        expect { patch_partners_details }.to change(Partner, :count).by(1)
        expect(legal_aid_application.reload.partner).to have_attributes(
          first_name: "John",
          last_name: "Doe",
          date_of_birth: Date.new(1981, 7, 11),
          national_insurance_number: "AB123456A",
        )
      end
    end
  end
end
