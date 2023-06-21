require "rails_helper"

RSpec.describe Providers::Partners::FullEmploymentDetailsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_partner) }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/partners/full_employment_details" do
    subject(:request) { get providers_legal_aid_application_partners_full_employment_details_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        request
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays the correct page content" do
        expect(response.body).to include(html_compare(I18n.t("shared.full_employment_details.page_heading_partner")))
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/partners/full_employment_details" do
    subject(:request) { patch providers_legal_aid_application_partners_full_employment_details_path(legal_aid_application), params: params.merge(submit_button) }

    let(:partner) { legal_aid_application.partner }
    let(:params) do
      {
        partner: {
          full_employment_details:,
        },
      }
    end

    context "when form is submitted with save and continue" do
      let(:submit_button) { { continue_button: "Save and continue" } }

      before do
        login_as provider
        request
      end

      context "when form is submitted with employment details" do
        let(:full_employment_details) { Faker::Lorem.paragraph }

        it "updates employment details for the partner" do
          expect(partner.reload.full_employment_details).to eq full_employment_details
        end
      end

      context "when no text is provided and params are invalid" do
        let(:full_employment_details) { "" }

        it "displays an error message" do
          expect(unescaped_response_body).to include(I18n.t("activemodel.errors.models.partner.attributes.full_employment_details.blank"))
        end
      end
    end

    context "when form submitted with save as draft button" do
      let(:submit_button) { { draft_button: "Save as draft" } }
      let(:full_employment_details) { Faker::Lorem.paragraph }

      context "when after success" do
        before do
          login_as provider
          request
        end

        it "updates employment details for the partner" do
          expect(partner.reload.full_employment_details).to eq full_employment_details
        end

        it "redirects to the list of applications" do
          expect(response).to redirect_to providers_legal_aid_applications_path
        end
      end
    end
  end
end
