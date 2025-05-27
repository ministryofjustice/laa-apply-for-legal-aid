require "rails_helper"

RSpec.describe Providers::Partners::FullEmploymentDetailsController do
  let(:application) { create(:legal_aid_application, :with_applicant_and_partner) }
  let(:partner) { application.partner }
  let(:provider) { application.provider }
  let(:before_actions) { {} }

  describe "GET /providers/applications/:legal_aid_application_id/partners/full_employment_details" do
    subject(:request) { get providers_legal_aid_application_partners_full_employment_details_path(application) }

    context "when the provider is not authenticated" do
      before { request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        before_actions
        login_as provider
        request
      end

      context "when the no job data is returned" do
        let(:before_actions) { create(:hmrc_response, :nil_response, legal_aid_application_id: application.id, owner_id: partner.id, owner_type: partner.class) }

        it "returns http success" do
          expect(response).to have_http_status(:ok)
        end

        it "displays the 'no data' message" do
          expect(response.body).to include(html_compare("HMRC has no record of the partner's employment in the last 3 months"))
        end
      end

      context "when the HMRC response is pending" do
        let(:before_actions) { create(:hmrc_response, :processing, legal_aid_application_id: application.id, owner_id: partner.id, owner_type: partner.class) }

        it "returns http success" do
          expect(response).to have_http_status(:ok)
        end

        it "displays the 'no data' message" do
          expect(response.body).to include(html_compare("HMRC has no record of the partner's employment in the last 3 months"))
        end
      end

      context "when the partner has multiple jobs" do
        let(:before_actions) do
          create(:hmrc_response, :multiple_employments_usecase1, legal_aid_application_id: application.id, owner_id: partner.id, owner_type: partner.class)
          create_list(:employment, 2, legal_aid_application: application, owner_id: partner.id, owner_type: partner.class)
        end

        it "returns http success" do
          expect(response).to have_http_status(:ok)
        end

        it "displays the 'multiple job' message" do
          expect(response.body).to include(html_compare("HMRC found a record of the partner's employment"))
          expect(response.body).to include(html_compare("HMRC says the partner had more than one job in the last 3 months."))
        end
      end

      context "when partner has no national insurance number" do
        let(:application) { create(:legal_aid_application, :with_partner_no_nino) }

        it "returns http success" do
          expect(response).to have_http_status(:ok)
        end

        it "displays the correct page content" do
          expect(response.body).to include(html_compare(I18n.t("shared.full_employment_details.page_heading_no_nino", individual: "the partner")))
        end
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/partners/full_employment_details" do
    subject(:request) { patch providers_legal_aid_application_partners_full_employment_details_path(application), params: params.merge(submit_button) }

    let(:partner) { application.partner }
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

        it "redirects to the next step" do
          expect(response).to have_http_status(:redirect)
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
          expect(response).to redirect_to in_progress_providers_legal_aid_applications_path
        end
      end
    end
  end
end
