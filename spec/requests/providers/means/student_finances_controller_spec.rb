require "rails_helper"

RSpec.describe Providers::Means::StudentFinancesController do
  let(:legal_aid_application) { create(:legal_aid_application, student_finance: nil) }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/means/student_finance" do
    subject(:request) do
      get providers_legal_aid_application_means_student_finance_path(legal_aid_application)
    end

    it "returns ok" do
      login_as provider

      request

      expect(response).to have_http_status(:ok)
    end

    context "when the application has student finance" do
      let(:legal_aid_application) { create(:legal_aid_application, student_finance: true) }

      it "checks the `Yes` radio button and displays the amount" do
        _student_finance = create(
          :irregular_income,
          amount: 1234.56,
          legal_aid_application:,
        )
        login_as provider

        request

        expect(page).to have_checked_field("Yes")
        expect(page).to have_field("irregular_income[amount]", with: "1234.56")
      end
    end

    context "when the application does not have student finance" do
      let(:legal_aid_application) { create(:legal_aid_application, student_finance: false) }

      it "checks the `No` radio button" do
        login_as provider

        request

        expect(page).to have_checked_field("No")
      end
    end

    context "when the provider is not authenticated" do
      before { request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is not authorised" do
      before do
        login_as create(:provider)
        request
      end

      it_behaves_like "an authenticated provider from a different firm"
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/means/student_finance" do
    subject(:request) do
      patch providers_legal_aid_application_means_student_finance_path(legal_aid_application),
            params: params.merge(button_clicked)
    end

    let(:params) { { irregular_income: { student_finance:, amount: } } }
    let(:student_finance) { "false" }
    let(:amount) { "" }
    let(:button_clicked) { {} }
    let(:continue_button) { { continue_button: "Save and continue" } }

    context "when the provider continues" do
      let(:button_clicked) { continue_button }

      context "when the provider selects `Yes`" do
        let(:student_finance) { "true" }
        let(:amount) { "5000" }

        it "updates the application" do
          login_as provider

          request

          expect(legal_aid_application.reload.student_finance).to be true
        end

        it "creates an irregular income" do
          login_as provider

          request

          student_finance = legal_aid_application.irregular_incomes.first
          expect(student_finance).to have_attributes(
            income_type: "student_loan",
            frequency: "annual",
            amount: 5000,
          )
        end
      end

      context "when the provider selects `No`" do
        let(:student_finance) { "false" }

        it "updates the application" do
          login_as provider

          request

          expect(legal_aid_application.reload.student_finance).to be false
        end

        it "does not create an irregular income" do
          expect(legal_aid_application.irregular_incomes.count).to be_zero
        end
      end

      context "when the application is using the bank upload journey" do
        let(:legal_aid_application) { create(:legal_aid_application, provider_received_citizen_consent: false) }

        let(:next_page) do
          providers_legal_aid_application_means_regular_outgoings_path(legal_aid_application)
        end

        it "redirects to the regular outgoings page" do
          login_as provider

          request

          expect(response).to redirect_to(next_page)
        end
      end

      context "when the application is not using the bank upload journey" do
        let(:next_page) do
          providers_legal_aid_application_means_identify_types_of_outgoing_path(legal_aid_application)
        end

        it "redirects to the identify types of outgoings page" do
          login_as provider

          request

          expect(response).to redirect_to(next_page)
        end
      end
    end

    context "when the application has student finance" do
      let(:student_finance) { "true" }
      let(:amount) { "5000" }

      it "updates the student finance amount" do
        student_finance = create(
          :irregular_income,
          legal_aid_application:,
          amount: 1234.56,
        )
        login_as provider

        request

        expect(IrregularIncome.count).to eq(1)
        expect(student_finance.reload.amount).to eq(5000)
      end
    end

    context "when the form is invalid" do
      let(:student_finance) { "" }

      it "displays an error message" do
        login_as provider

        request

        expect(page).to have_error_message(
          "Select yes if your client receives student finance",
        )
      end
    end

    context "when the provider is not authenticated" do
      before { request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is not authorised" do
      before do
        login_as create(:provider)
        request
      end

      it_behaves_like "an authenticated provider from a different firm"
    end
  end

  def have_error_message(message)
    have_css(".govuk-error-summary__list > li", text: message)
  end
end
