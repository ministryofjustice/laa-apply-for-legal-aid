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
      it "redirects to the next page" do
        legal_aid_application = create(:legal_aid_application)

        get providers_legal_aid_application_means_housing_benefits_path(legal_aid_application)

        expect(response).to have_http_status(:redirect)
      end
    end

    context "when the provider is not authorised" do
      it "redirects to the next page" do
        legal_aid_application = create(:legal_aid_application)
        provider = create(:provider)
        login_as provider

        get providers_legal_aid_application_means_housing_benefits_path(legal_aid_application)

        expect(response).to have_http_status(:redirect)
      end
    end

    context "when the applicant has housing outgoing category" do
      it "renders the correct content" do
        _housing_benefit = create(:transaction_type, :housing_benefit)
        transaction_type = create(:transaction_type, :rent_or_mortgage)
        legal_aid_application = create(:legal_aid_application, :with_applicant_and_partner, :with_non_passported_state_machine, :applicant_entering_means, transaction_types: [transaction_type])
        laa_transaction_type = create(:legal_aid_application_transaction_type, legal_aid_application_id: legal_aid_application.id,
                                                                               transaction_type_id: transaction_type.id,
                                                                               owner_type: "Applicant", owner_id: legal_aid_application.applicant.id)

        legal_aid_application.legal_aid_application_transaction_types << laa_transaction_type
        login_as legal_aid_application.provider

        get providers_legal_aid_application_means_housing_benefits_path(legal_aid_application)
        expect(response.body).to include(I18n.t("providers.means.housing_benefits.show.page_heading", individual: I18n.t("generic.client")))
      end
    end

    context "when the partner has housing outgoing category" do
      it "renders the correct content" do
        _housing_benefit = create(:transaction_type, :housing_benefit)
        transaction_type = create(:transaction_type, :rent_or_mortgage)
        legal_aid_application = create(:legal_aid_application, :with_applicant_and_partner, :with_non_passported_state_machine, :applicant_entering_means, transaction_types: [transaction_type])
        laa_transaction_type = create(:legal_aid_application_transaction_type, legal_aid_application_id: legal_aid_application.id,
                                                                               transaction_type_id: transaction_type.id,
                                                                               owner_type: "Partner", owner_id: legal_aid_application.partner.id)

        legal_aid_application.legal_aid_application_transaction_types << laa_transaction_type
        login_as legal_aid_application.provider

        get providers_legal_aid_application_means_housing_benefits_path(legal_aid_application)
        expect(response.body).to include(I18n.t("providers.means.housing_benefits.show.page_heading", individual: I18n.t("generic.partner")))
      end
    end

    context "when both the applicant and the partner have housing outgoing category" do
      it "renders the correct content" do
        _housing_benefit = create(:transaction_type, :housing_benefit)
        transaction_type = create(:transaction_type, :rent_or_mortgage)
        legal_aid_application = create(:legal_aid_application, :with_applicant_and_partner, :with_non_passported_state_machine, :applicant_entering_means, transaction_types: [transaction_type])
        laa_transaction_type_applicant = create(:legal_aid_application_transaction_type, legal_aid_application_id: legal_aid_application.id,
                                                                                         transaction_type_id: transaction_type.id,
                                                                                         owner_type: "Applicant", owner_id: legal_aid_application.applicant.id)
        laa_transaction_type_partner = create(:legal_aid_application_transaction_type, legal_aid_application_id: legal_aid_application.id,
                                                                                       transaction_type_id: transaction_type.id,
                                                                                       owner_type: "Partner", owner_id: legal_aid_application.partner.id)

        legal_aid_application.legal_aid_application_transaction_types << laa_transaction_type_applicant
        legal_aid_application.legal_aid_application_transaction_types << laa_transaction_type_partner

        legal_aid_application.provider.permissions << Permission.find_or_create_by(role: "application.non_passported.bank_statement_upload.*")
        legal_aid_application.update!(provider_received_citizen_consent: false)

        login_as legal_aid_application.provider

        get providers_legal_aid_application_means_housing_benefits_path(legal_aid_application)
        expect(response.body).to include(I18n.t("providers.means.housing_benefits.show.page_heading", individual: I18n.t("generic.client_or_partner")))
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/means/housing_benefits" do
    it "updates the application and redirects to the next page" do
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
      expect(response).to have_http_status(:redirect)
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

        expect(response).to have_http_status(:unprocessable_content)
        expect(page).to have_css("p", class: "govuk-error-message", text: "Select yes if your client receives Housing Benefit")
        expect(legal_aid_application.reload.applicant_in_receipt_of_housing_benefit).to be_nil
      end
    end

    context "when the provider is not authenticated" do
      it "redirects to the next page" do
        legal_aid_application = create(:legal_aid_application)

        patch providers_legal_aid_application_means_housing_benefits_path(legal_aid_application)

        expect(response).to have_http_status(:redirect)
      end
    end

    context "when the provider is not authorised" do
      it "redirects to the next page" do
        legal_aid_application = create(:legal_aid_application)
        provider = create(:provider)
        login_as provider

        patch providers_legal_aid_application_means_housing_benefits_path(legal_aid_application)

        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
