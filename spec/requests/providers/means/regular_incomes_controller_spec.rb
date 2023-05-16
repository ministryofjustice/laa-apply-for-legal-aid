require "rails_helper"

RSpec.describe Providers::Means::RegularIncomesController do
  describe "GET /providers/applications/:legal_aid_application_id/means/regular_incomes" do
    it "returns ok" do
      legal_aid_application = create(:legal_aid_application, :with_applicant)
      provider = legal_aid_application.provider
      login_as provider

      get providers_legal_aid_application_means_regular_incomes_path(legal_aid_application)

      expect(response).to have_http_status(:ok)
    end

    context "when the application has regular transactions" do
      it "renders the income data" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        applicant = legal_aid_application.applicant
        benefits = create(:transaction_type, :benefits)
        _transaction_type = create(
          :legal_aid_application_transaction_type,
          legal_aid_application:,
          transaction_type: benefits,
        )
        _regular_transaction = create(
          :regular_transaction,
          legal_aid_application:,
          transaction_type: benefits,
          amount: 500,
          frequency: "weekly",
          owner_id: applicant.id,
          owner_type: "Applicant",
        )
        provider = legal_aid_application.provider
        login_as provider

        get providers_legal_aid_application_means_regular_incomes_path(legal_aid_application)

        expect(page).to have_checked_field("Benefits")
        benefits_amount = page.find_field("providers-means-regular-income-form-benefits-amount-field").value
        expect(benefits_amount).to eq("500.0")
        frequency_amount = page.find_field("providers-means-regular-income-form-benefits-frequency-weekly-field").value
        expect(frequency_amount).to eq("weekly")
      end
    end

    context "when the provider is not authenticated" do
      it "redirects to the provider login page" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)

        get providers_legal_aid_application_means_regular_incomes_path(legal_aid_application)

        expect(response).to redirect_to(new_provider_session_path)
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/means/regular_incomes" do
    before { create(:transaction_type, :housing_benefit) }

    context "when none is selected" do
      it "updates the application and redirects to the student finance page" do
        legal_aid_application = create(
          :legal_aid_application,
          :with_applicant,
          no_credit_transaction_types_selected: false,
        )
        provider = legal_aid_application.provider
        login_as provider
        params = {
          providers_means_regular_income_form: {
            transaction_type_ids: ["", "none"],
          },
        }

        patch(providers_legal_aid_application_means_regular_incomes_path(legal_aid_application), params:)

        expect(response).to redirect_to(providers_legal_aid_application_means_student_finance_path(legal_aid_application))
        expect(legal_aid_application.reload.no_credit_transaction_types_selected).to be true
      end
    end

    context "when regular transactions are selected" do
      it "updates the application and redirects to the cash income page" do
        legal_aid_application = create(
          :legal_aid_application,
          :with_applicant,
          no_credit_transaction_types_selected: true,
        )
        benefits = create(:transaction_type, :benefits)
        pension = create(:transaction_type, :pension)
        provider = legal_aid_application.provider
        login_as provider
        params = {
          providers_means_regular_income_form: {
            transaction_type_ids: ["", benefits.id, pension.id],
            benefits_amount: 250,
            benefits_frequency: "weekly",
            pension_amount: 100,
            pension_frequency: "monthly",
          },
        }

        patch(providers_legal_aid_application_means_regular_incomes_path(legal_aid_application), params:)

        expect(response).to redirect_to(providers_legal_aid_application_means_cash_income_path(legal_aid_application))
        expect(legal_aid_application.reload.no_credit_transaction_types_selected).to be false
        identified_income = legal_aid_application.regular_transactions.credits
        expect(identified_income.pluck(:transaction_type_id, :amount, :frequency))
          .to contain_exactly([benefits.id, 250, "weekly"], [pension.id, 100, "monthly"])
      end
    end

    context "when the form is invalid" do
      it "returns unprocessable entity, renders errors, and does not update the application" do
        legal_aid_application = create(
          :legal_aid_application,
          :with_applicant,
          no_credit_transaction_types_selected: nil,
        )
        benefits = create(:transaction_type, :benefits)
        maintenance_in_payment = create(:regular_transaction, :maintenance_in, legal_aid_application:)
        provider = legal_aid_application.provider
        login_as provider
        params = {
          providers_means_regular_income_form: {
            transaction_type_ids: ["", benefits.id],
            benefits_amount: "",
            benefits_frequency: "",
          },
        }

        patch(providers_legal_aid_application_means_regular_incomes_path(legal_aid_application), params:)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(page).to have_css("p", class: "govuk-error-message", text: "Enter the amount of benefits received")
        expect(page).to have_css("p", class: "govuk-error-message", text: "Select how often your client receives benefits")
        expect(legal_aid_application.reload.no_credit_transaction_types_selected).to be_nil
        identified_income = legal_aid_application.regular_transactions.credits
        expect(identified_income).to contain_exactly(maintenance_in_payment)
      end
    end

    context "when checking answers and none is selected" do
      it "updates the application and redirects to the means summaries page" do
        legal_aid_application = create(
          :legal_aid_application,
          :with_applicant,
          :with_non_passported_state_machine,
          :checking_means_income,
          no_credit_transaction_types_selected: false,
        )
        provider = legal_aid_application.provider
        login_as provider
        params = { providers_means_regular_income_form: { transaction_type_ids: ["", "none"] } }

        patch(providers_legal_aid_application_means_regular_incomes_path(legal_aid_application), params:)

        expect(response).to redirect_to(providers_legal_aid_application_means_check_income_answers_path(legal_aid_application))
        expect(legal_aid_application.reload.no_credit_transaction_types_selected).to be true
      end
    end

    context "when checking answers and regular transactions are selected" do
      it "updates the application and redirects to the cash income page" do
        legal_aid_application = create(
          :legal_aid_application,
          :with_applicant,
          :with_non_passported_state_machine,
          :checking_means_income,
          no_credit_transaction_types_selected: true,
        )
        benefits = create(:transaction_type, :benefits)
        pension = create(:transaction_type, :pension)
        provider = legal_aid_application.provider
        login_as provider
        params = {
          providers_means_regular_income_form: {
            transaction_type_ids: ["", benefits.id, pension.id],
            benefits_amount: 250,
            benefits_frequency: "weekly",
            pension_amount: 100,
            pension_frequency: "monthly",
          },
        }

        patch(providers_legal_aid_application_means_regular_incomes_path(legal_aid_application), params:)

        expect(response).to redirect_to(providers_legal_aid_application_means_cash_income_path(legal_aid_application))
        expect(legal_aid_application.reload.no_credit_transaction_types_selected).to be false
        identified_income = legal_aid_application.regular_transactions.credits
        expect(identified_income.pluck(:transaction_type_id, :amount, :frequency))
          .to contain_exactly([benefits.id, 250, "weekly"], [pension.id, 100, "monthly"])
      end
    end

    context "when the provider is not authenticated" do
      it "redirects to the provider login page" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)

        patch providers_legal_aid_application_means_regular_incomes_path(legal_aid_application)

        expect(response).to redirect_to(new_provider_session_path)
      end
    end
  end
end
