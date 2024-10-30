require "rails_helper"

RSpec.describe Providers::Means::CapitalDisregards::MandatoryController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:provider) { legal_aid_application.provider }

  describe "GET providers/applications/:id/means/capital_disregards/disregarded_payments" do
    subject(:get_request) { get providers_legal_aid_application_means_capital_disregards_mandatory_path(legal_aid_application) }

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

      it "displays the show page" do
        expect(response.body).to include("Disregarded payments")
      end
    end
  end

  describe "PATCH providers/applications/:id/means/capital_disregards/disregarded_payments" do
    let(:none_selected) { "" }
    let(:mandatory_capital_disregards) { %w[backdated_benefits government_cost_of_living] }
    let(:params) do
      {
        providers_means_capital_disregards_mandatory_form: {
          mandatory_capital_disregards:,
          none_selected:,
        },
        continue_button: "Save and continue",
      }
    end

    before do
      login_as provider
      patch(providers_legal_aid_application_means_capital_disregards_mandatory_path(legal_aid_application), params:)
    end

    context "with valid params" do
      it "updates the record" do
        expect(legal_aid_application.mandatory_capital_disregards.count).to eq 2
        expect(legal_aid_application.mandatory_capital_disregards.pluck(:mandatory)).to contain_exactly(true, true)
        expect(legal_aid_application.mandatory_capital_disregards.pluck(:name)).to match_array(%w[backdated_benefits government_cost_of_living])
      end
    end

    context "when checking passported answers" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_passported_state_machine, :checking_passported_answers) }

      it "redirects to the check passported answers page" do
        expect(response).to redirect_to providers_legal_aid_application_check_passported_answers_path(legal_aid_application)
      end
    end

    context "when checking non-passported answers" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine, :checking_non_passported_means) }

      it "redirects to the non-passported capital CYA page" do
        expect(response).to redirect_to providers_legal_aid_application_check_capital_answers_path(legal_aid_application)
      end
    end

    context "with no mandatory disregard types selected" do
      let(:mandatory_capital_disregards) { "" }

      context "with 'none of these' checkbox selected" do
        let(:none_selected) { "true" }

        it "does not create mandatory disregards" do
          expect(legal_aid_application.mandatory_capital_disregards.count).to eq 0
        end
      end

      context "with 'none of these' checkbox not selected" do
        let(:none_selected) { "" }

        it "the response includes the error message" do
          expect(response.body).to include(I18n.t("activemodel.errors.models.mandatory_capital_disregards.attributes.base.none_selected"))
        end
      end
    end
  end
end
