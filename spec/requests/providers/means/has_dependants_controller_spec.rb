require "rails_helper"

RSpec.describe Providers::Means::HasDependantsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:login) { login_as legal_aid_application.provider }

  before { login }

  describe "GET /providers/:application_id/means/has_dependants" do
    subject(:request) { get providers_legal_aid_application_means_has_dependants_path(legal_aid_application) }

    it "returns http success" do
      request
      expect(response).to have_http_status(:ok)
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }

      before { request }

      it_behaves_like "a provider not authenticated"
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/means/has_dependants" do
    subject(:request) do
      patch(
        providers_legal_aid_application_means_has_dependants_path(legal_aid_application),
        params:,
      )
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }
      let(:params) { nil }

      before { request }

      it_behaves_like "a provider not authenticated"
    end

    context "when has_dependants is nil" do
      let(:has_dependants) { nil }
      let(:params) do
        { legal_aid_application: { has_dependants: } }
      end

      it "renders successfully" do
        request
        expect(response).to have_http_status(:ok)
      end

      it "displays error" do
        request
        expect(response.body).to include("govuk-error-summary")
      end
    end

    context "when there are valid params" do
      context "and the provider answers yes" do
        let(:params) { { legal_aid_application: { has_dependants: "true" } } }

        it "sets has_dependants to true" do
          expect { request }.to change { legal_aid_application.reload.has_dependants }.from(nil).to(true)
        end

        it "redirects to next page" do
          request
          expect(response).to have_http_status(:redirect)
        end
      end

      context "and the provider answers no" do
        let(:params) { { legal_aid_application: { has_dependants: "false" } } }

        it "sets has_dependants to false" do
          expect { request }.to change { legal_aid_application.reload.has_dependants }.from(nil).to(false)
        end

        it "redirects to the check answers income page" do
          request
          expect(response).to redirect_to(providers_legal_aid_application_means_check_income_answers_path(legal_aid_application))
        end
      end
    end

    context "when provider checking answers and no" do
      let(:legal_aid_application) do
        create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine,
               :checking_means_income)
      end
      let(:params) { { legal_aid_application: { has_dependants: "false" } } }

      it "redirects to the check answers income page" do
        request
        expect(response).to redirect_to(providers_legal_aid_application_means_check_income_answers_path(legal_aid_application))
      end
    end

    context "when provider checking answers and no dependants and yes" do
      let(:legal_aid_application) do
        create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine,
               :checking_means_income)
      end
      let(:params) { { legal_aid_application: { has_dependants: "true" } } }

      it "redirects to the add dependant details page" do
        request
        expect(response).to redirect_to(new_providers_legal_aid_application_means_dependant_path(legal_aid_application))
      end
    end

    context "when provider checking answers of citizen and previously added dependants and yes" do
      let(:legal_aid_application) do
        create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine,
               :checking_means_income, :with_dependant)
      end
      let(:params) { { legal_aid_application: { has_dependants: "true" } } }

      it "redirects to the has other dependants page" do
        request
        expect(response).to redirect_to(providers_legal_aid_application_means_has_other_dependants_path(legal_aid_application))
      end
    end

    context "when the params are invalid - nothing specified" do
      let(:params) { {} }

      it "returns http_success" do
        request
        expect(response).to have_http_status(:ok)
      end

      it "does not update the record" do
        request
        expect(legal_aid_application.reload.has_dependants).to be_nil
      end

      it "the response includes the error message" do
        request
        expect(response.body).to include(I18n.t("activemodel.errors.models.legal_aid_application.attributes.has_dependants.blank"))
      end
    end
  end
end
