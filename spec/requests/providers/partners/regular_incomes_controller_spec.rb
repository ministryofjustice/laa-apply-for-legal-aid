require "rails_helper"

RSpec.describe Providers::Partners::RegularIncomesController do
  describe "GET /providers/applications/:legal_aid_application_id/partners/regular_incomes" do
    it "returns ok" do
      legal_aid_application = create(:legal_aid_application, :with_applicant_and_partner)
      provider = legal_aid_application.provider
      login_as provider

      get providers_legal_aid_application_partners_regular_incomes_path(legal_aid_application)

      expect(response).to have_http_status(:ok)
    end

    context "when the application has regular transactions" do
      it "renders the income data" do
        legal_aid_application = create(:legal_aid_application, :with_applicant_and_partner)
        partner = legal_aid_application.partner
        pension = create(:transaction_type, :pension)
        _transaction_type = create(
          :legal_aid_application_transaction_type,
          legal_aid_application:,
          transaction_type: pension,
        )
        _regular_transaction = create(
          :regular_transaction,
          legal_aid_application:,
          transaction_type: pension,
          amount: 500,
          frequency: "weekly",
          owner_id: partner.id,
          owner_type: "Partner",
        )
        provider = legal_aid_application.provider
        login_as provider

        get providers_legal_aid_application_partners_regular_incomes_path(legal_aid_application)

        expect(page).to have_checked_field("Pension")
        pension_amount = page.find_field("providers-partners-regular-income-form-pension-amount-field").value
        expect(pension_amount).to eq("500")
        frequency_amount = page.find_field("providers-partners-regular-income-form-pension-frequency-weekly-field").value
        expect(frequency_amount).to eq("weekly")
      end
    end

    context "when the provider is not authenticated" do
      it "redirects to the provider login page" do
        legal_aid_application = create(:legal_aid_application, :with_applicant_and_partner)

        get providers_legal_aid_application_means_regular_incomes_path(legal_aid_application)

        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/partners/regular_incomes" do
    before { create(:transaction_type, :housing_benefit) }

    context "when none is selected" do
      it "updates the application and redirects to the student finance page" do
        legal_aid_application = create(
          :legal_aid_application,
          :with_applicant_and_partner,
          no_credit_transaction_types_selected: false,
        )
        provider = legal_aid_application.provider
        login_as provider
        params = {
          providers_partners_regular_income_form: {
            transaction_type_ids: ["", "none"],
          },
        }

        patch(providers_legal_aid_application_partners_regular_incomes_path(legal_aid_application), params:)

        expect(response).to have_http_status(:redirect)
        expect(legal_aid_application.reload.no_credit_transaction_types_selected).to be true
      end
    end

    context "when regular transactions are selected" do
      it "updates the application and redirects to the cash income page" do
        legal_aid_application = create(
          :legal_aid_application,
          :with_applicant_and_partner,
          no_credit_transaction_types_selected: true,
        )
        maintenance_in = create(:transaction_type, :maintenance_in)
        pension = create(:transaction_type, :pension)
        provider = legal_aid_application.provider
        login_as provider
        params = {
          providers_partners_regular_income_form: {
            transaction_type_ids: ["", maintenance_in.id, pension.id],
            maintenance_in_amount: 250,
            maintenance_in_frequency: "weekly",
            pension_amount: 100,
            pension_frequency: "monthly",
          },
        }

        patch(providers_legal_aid_application_partners_regular_incomes_path(legal_aid_application), params:)

        expect(response).to have_http_status(:redirect)
        expect(legal_aid_application.reload.no_credit_transaction_types_selected).to be false
        identified_income = legal_aid_application.regular_transactions.credits
        expect(identified_income.pluck(:transaction_type_id, :amount, :frequency))
          .to contain_exactly([maintenance_in.id, 250, "weekly"], [pension.id, 100, "monthly"])
      end
    end

    context "when the form is invalid" do
      it "returns unprocessable entity, renders errors, and does not update the application" do
        legal_aid_application = create(
          :legal_aid_application,
          :with_applicant_and_partner,
          no_credit_transaction_types_selected: nil,
        )
        pension = create(:transaction_type, :pension)
        maintenance_in_payment = create(:regular_transaction, :maintenance_in, legal_aid_application:)
        provider = legal_aid_application.provider
        login_as provider
        params = {
          providers_partners_regular_income_form: {
            transaction_type_ids: ["", pension.id],
            benefits_amount: "",
            benefits_frequency: "",
          },
        }

        patch(providers_legal_aid_application_partners_regular_incomes_path(legal_aid_application), params:)

        expect(response).to have_http_status(:unprocessable_content)
        expect(page).to have_css("p", class: "govuk-error-message", text: "Enter the amount of pension received")
        expect(page).to have_css("p", class: "govuk-error-message", text: "Select how often the partner receives pension")
        expect(legal_aid_application.reload.no_credit_transaction_types_selected).to be_nil
        identified_income = legal_aid_application.regular_transactions.credits
        expect(identified_income).to contain_exactly(maintenance_in_payment)
      end
    end

    context "when checking answers and none is selected" do
      it "updates the application and redirects to the means summaries page" do
        legal_aid_application = create(
          :legal_aid_application,
          :with_applicant_and_partner,
          :with_non_passported_state_machine,
          :checking_means_income,
          no_credit_transaction_types_selected: false,
        )
        provider = legal_aid_application.provider
        login_as provider
        params = { providers_partners_regular_income_form: { transaction_type_ids: ["", "none"] } }

        patch(providers_legal_aid_application_partners_regular_incomes_path(legal_aid_application), params:)

        expect(response).to have_http_status(:redirect)
        expect(legal_aid_application.reload.no_credit_transaction_types_selected).to be true
      end
    end

    context "when checking answers and regular transactions are selected" do
      it "updates the application and redirects to the cash income page" do
        legal_aid_application = create(
          :legal_aid_application,
          :with_applicant_and_partner,
          :with_non_passported_state_machine,
          :checking_means_income,
          no_credit_transaction_types_selected: true,
        )
        maintenance_in = create(:transaction_type, :maintenance_in)
        pension = create(:transaction_type, :pension)
        provider = legal_aid_application.provider
        login_as provider
        params = {
          providers_partners_regular_income_form: {
            transaction_type_ids: ["", maintenance_in.id, pension.id],
            maintenance_in_amount: 250,
            maintenance_in_frequency: "weekly",
            pension_amount: 100,
            pension_frequency: "monthly",
          },
        }

        patch(providers_legal_aid_application_partners_regular_incomes_path(legal_aid_application), params:)

        expect(response).to have_http_status(:redirect)
        expect(legal_aid_application.reload.no_credit_transaction_types_selected).to be false
        identified_income = legal_aid_application.regular_transactions.credits
        expect(identified_income.pluck(:transaction_type_id, :amount, :frequency))
          .to contain_exactly([maintenance_in.id, 250, "weekly"], [pension.id, 100, "monthly"])
      end
    end

    context "when the provider is not authenticated" do
      it "redirects to the provider login page" do
        legal_aid_application = create(:legal_aid_application, :with_applicant_and_partner)

        patch providers_legal_aid_application_partners_regular_incomes_path(legal_aid_application)

        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
