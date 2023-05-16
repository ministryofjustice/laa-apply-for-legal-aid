require "rails_helper"

RSpec.describe Providers::Means::HousingBenefitsController do
  describe "GET /providers/applications/:legal_aid_application_id/means/housing_benefits" do
    it "returns ok" do
      _housing_benefit = create(:transaction_type, :housing_benefit)
      legal_aid_application = create(:legal_aid_application)
      _transaction_type = create(:transaction_type, :housing_benefit)
      provider = legal_aid_application.provider
      login_as provider

      get providers_legal_aid_application_means_housing_benefits_path(legal_aid_application)

      expect(response).to have_http_status(:ok)
    end

    context "when the application has a housing benefit transaction" do
      it "renders the housing benefit data" do
        legal_aid_application = create(
          :legal_aid_application,
          :with_applicant,
          applicant_in_receipt_of_housing_benefit: true,
        )
        transaction_type = create(:transaction_type, :housing_benefit)
        _legal_aid_application_transaction_type = create(
          :legal_aid_application_transaction_type,
          legal_aid_application:,
          transaction_type:,
        )
        housing_benefit = create(
          :regular_transaction,
          amount: 100,
          frequency: "weekly",
          legal_aid_application:,
          transaction_type:,
          owner_id: legal_aid_application.applicant.id,
          owner_type: "Applicant",
        )
        provider = legal_aid_application.provider
        login_as provider

        get providers_legal_aid_application_means_housing_benefits_path(legal_aid_application)

        expect(page).to have_checked_field(
          "providers_means_housing_benefit_form[transaction_type_ids]",
        )
        expect(page).to have_field(
          "providers_means_housing_benefit_form[housing_benefit_amount]",
          with: housing_benefit.amount,
        )
        expect(page).to have_field(
          "providers_means_housing_benefit_form[housing_benefit_frequency]",
          with: housing_benefit.frequency,
        )
      end
    end

    context "when the provider is not authenticated" do
      it "redirects to the provider login page" do
        legal_aid_application = create(:legal_aid_application)

        get providers_legal_aid_application_means_housing_benefits_path(legal_aid_application)

        expect(response).to redirect_to(new_provider_session_path)
      end
    end

    context "when the provider is not authorised" do
      it "redirects to the access denied page" do
        legal_aid_application = create(:legal_aid_application)
        provider = create(:provider)
        login_as provider

        get providers_legal_aid_application_means_housing_benefits_path(legal_aid_application)

        expect(response).to redirect_to(error_path(:access_denied))
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/means/housing_benefits" do
    it "updates the application and redirects to the cash outgoings page" do
      legal_aid_application = create(
        :legal_aid_application,
        applicant_in_receipt_of_housing_benefit: nil,
      )
      _transaction_type = create(:transaction_type, :housing_benefit)
      provider = legal_aid_application.provider
      login_as provider
      params = {
        "providers_means_housing_benefit_form" => {
          "transaction_type_ids" => "none",
          "housing_benefit_amount" => "",
          "housing_benefit_frequency" => "",
        },
      }

      patch(providers_legal_aid_application_means_housing_benefits_path(legal_aid_application), params:)

      expect(legal_aid_application.reload.applicant_in_receipt_of_housing_benefit).to be false
      expect(response).to redirect_to(providers_legal_aid_application_means_cash_outgoing_path(legal_aid_application))
    end

    context "when the form is invalid" do
      it "returns unprocessable entity, renders errors, and does not update the application" do
        _housing_benefit = create(:transaction_type, :housing_benefit)
        legal_aid_application = create(
          :legal_aid_application,
          applicant_in_receipt_of_housing_benefit: nil,
        )
        _transaction_type = create(:transaction_type, :housing_benefit)
        provider = legal_aid_application.provider
        login_as provider
        params = {
          "providers_means_housing_benefit_form" => {
            "transaction_type_ids" => "",
            "housing_benefit_amount" => "",
            "housing_benefit_frequency" => "",
          },
        }

        patch(providers_legal_aid_application_means_housing_benefits_path(legal_aid_application), params:)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(page).to have_css("p", class: "govuk-error-message", text: "Select yes if your client receives Housing Benefit")
        expect(legal_aid_application.reload.applicant_in_receipt_of_housing_benefit).to be_nil
      end
    end

    context "when the provider is not authenticated" do
      it "redirects to the provider login page" do
        legal_aid_application = create(:legal_aid_application)

        patch providers_legal_aid_application_means_housing_benefits_path(legal_aid_application)

        expect(response).to redirect_to(new_provider_session_path)
      end
    end

    context "when the provider is not authorised" do
      it "redirects to the access denied page" do
        legal_aid_application = create(:legal_aid_application)
        provider = create(:provider)
        login_as provider

        patch providers_legal_aid_application_means_housing_benefits_path(legal_aid_application)

        expect(response).to redirect_to(error_path(:access_denied))
      end
    end
  end
end
