require "rails_helper"

RSpec.describe Providers::Means::PropertyDetailsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

  describe "GET /providers/applications/:id/means/property_details" do
    subject(:request) { get providers_legal_aid_application_means_property_details_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as legal_aid_application.provider
        request
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      context "when property is mortgaged" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_own_home_mortgaged) }

        it "shows the outstanding mortgage question" do
          expect(response.body).to include(I18n.t("providers.means.property_details.show.mortgage_question"))
        end
      end

      context "when property is owned outright" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_own_home_owned_outright) }

        it "does not show the outstanding mortgage question" do
          expect(response.body).not_to include(I18n.t("providers.means.property_details.show.mortgage_question"))
        end
      end

      context "when the application has no partner" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_own_home_mortgaged) }

        it "shows the correct content" do
          expect(response.body).not_to include(I18n.t("providers.means.property_details.show.percentage_question.partner"))
        end
      end

      context "when the application has a partner with no contrary interest" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_partner, :with_own_home_mortgaged) }

        it "shows the correct content" do
          expect(response.body).to include(I18n.t("providers.means.property_details.show.percentage_question.partner"))
        end
      end
    end
  end

  describe "PATCH /providers/applications/:id/means/property_details" do
    subject(:request) { patch providers_legal_aid_application_means_property_details_path(legal_aid_application), params: params.merge(submit_button) }

    let(:property_value) { rand(1...1_000_000.0).round(2) }
    let(:outstanding_mortgage_amount) { rand(1...500_000.0).round(2) }
    let(:shared_ownership) { LegalAidApplication::SHARED_OWNERSHIP_YES_REASONS.first }
    let(:percentage_home) { rand(1...100) }

    let(:params) do
      {
        legal_aid_application: { property_value:, outstanding_mortgage_amount:, shared_ownership:, percentage_home: },
        legal_aid_application_id: legal_aid_application.id,
      }
    end

    before do
      login_as legal_aid_application.provider
      request
    end

    context "when continue button is pressed" do
      let(:submit_button) do
        {
          continue_button: "Continue",
        }
      end

      context "when params are invalid" do
        let(:params) { {} }

        it "shows an error" do
          expect(response.body).to include("govuk-error-summary__title")
        end
      end

      context "when property is mortgaged and with valid values" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_own_home_mortgaged) }

        it "updates the property value on the legal aid legal_aid_application" do
          expect(legal_aid_application.reload.property_value).to eq(property_value)
        end

        it "updates the outstanding mortgage amount on the legal aid legal_aid_application" do
          expect(legal_aid_application.reload.outstanding_mortgage_amount).to eq(outstanding_mortgage_amount)
        end

        it "updates the shared ownership attribute on the legal aid legal_aid_application" do
          expect(legal_aid_application.reload.shared_ownership).to match(shared_ownership)
        end

        it "updates the percentage home value on the legal aid legal_aid_application" do
          expect(legal_aid_application.reload.percentage_home).to eq(percentage_home)
        end

        it "redirects to the next page" do
          expect(response).to have_http_status(:redirect)
        end
      end

      context "when property is owned outright and with valid values" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_own_home_owned_outright) }
        let(:property_value) { rand(1...1_000_000.0).round(2) }
        let(:outstanding_mortgage_amount) { "" }
        let(:shared_ownership) { LegalAidApplication::SHARED_OWNERSHIP_YES_REASONS.first }
        let(:percentage_home) { rand(1...100) }

        it "updates the property value on the legal aid legal_aid_application" do
          expect(legal_aid_application.reload.property_value).to eq(property_value)
        end

        it "does not update the outstanding mortgage amount on the legal aid legal_aid_application" do
          expect(legal_aid_application.reload.outstanding_mortgage_amount).to be_nil
        end

        it "updates the shared ownership attribute on the legal aid legal_aid_application" do
          expect(legal_aid_application.reload.shared_ownership).to match(shared_ownership)
        end

        it "updates the percentage home value on the legal aid legal_aid_application" do
          expect(legal_aid_application.reload.percentage_home).to eq(percentage_home)
        end

        it "redirects to the next page" do
          expect(response).to have_http_status(:redirect)
        end
      end

      context "when property values are missing" do
        let(:property_value) { "" }

        it "shows an error message for the missing value" do
          expect(response.body).to include("govuk-error-summary__title")
          expect(unescaped_response_body).to include(I18n.t("activemodel.errors.models.legal_aid_application.attributes.property_value.blank"))
        end

        it "does not record the value in the legal aid application table" do
          legal_aid_application.reload
          expect(legal_aid_application.property_value).to be_nil
        end
      end

      context "when a value is invalid" do
        let(:percentage_home) { "150" }

        it "shows an error message for the missing value" do
          expect(response.body).to include("govuk-error-summary__title")
          expect(response.body).to include(I18n.t("activemodel.errors.models.legal_aid_application.attributes.percentage_home.less_than_or_equal_to"))
        end
      end
    end

    context "when Save as draft button is pressed" do
      let(:submit_button) do
        {
          draft_button: "Save as draft",
        }
      end

      context "when valid property values are entered" do
        it "records the values in the legal aid legal_aid_application table" do
          legal_aid_application.reload
          expect(legal_aid_application.property_value).to eq(property_value)
        end

        it "redirects to the applications page" do
          expect(response).to redirect_to in_progress_providers_legal_aid_applications_path
        end
      end

      context "when no property values are entered" do
        let(:property_value) { "" }

        it "redirects provider to provider's applications page" do
          expect(response).to redirect_to in_progress_providers_legal_aid_applications_path
        end
      end
    end

    context "when checking answers" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :checking_non_passported_means) }

      let(:submit_button) do
        {
          continue_button: "Continue",
        }
      end

      it "redirects to the restrictions page" do
        expect(response).to redirect_to(providers_legal_aid_application_means_restrictions_path(legal_aid_application))
      end
    end
  end
end
