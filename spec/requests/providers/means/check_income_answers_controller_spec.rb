require "rails_helper"

RSpec.describe Providers::Means::CheckIncomeAnswersController do
  include ActionView::Helpers::NumberHelper

  let(:provider) { create(:provider) }
  let(:applicant) { create(:applicant) }
  let(:pension) { create(:transaction_type, :pension) }
  let(:bank_provider) { create(:bank_provider, applicant:) }
  let(:bank_account) { create(:bank_account, bank_provider:) }

  let(:legal_aid_application) do
    create(:legal_aid_application,
           :with_negative_benefit_check_result,
           :with_non_passported_state_machine,
           :checking_means_income,
           :with_proceedings,
           :with_delegated_functions_on_proceedings,
           df_options: { DA001: Date.current },
           applicant:,
           provider:)
  end

  before do
    create(
      :legal_aid_application_transaction_type,
      legal_aid_application:,
      transaction_type: pension,
      owner_type: "Applicant",
      owner_id: legal_aid_application.applicant.id,
    )
  end

  describe "GET /providers/applications/:legal_aid_application_id/means/check_income_answers" do
    subject(:request) { get providers_legal_aid_application_means_check_income_answers_path(legal_aid_application) }

    let!(:bank_transactions) do
      create_list(
        :bank_transaction, 3,
        transaction_type: pension,
        bank_account:,
        amount: 111.0
      )
    end

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

      it "sets the state to checking means income" do
        expect(legal_aid_application.reload).to be_checking_means_income
      end

      it "displays the bank transaction data" do
        total_amount = bank_transactions.sum(&:amount)
        expect(total_amount).not_to be_zero
        expect(response.body).to include(ActiveSupport::NumberHelper.gds_number_to_currency(total_amount))
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/means/check_answers_income" do
    subject(:request) { patch providers_legal_aid_application_means_check_income_answers_path(legal_aid_application) }

    before do
      login_as provider
      request
    end

    it "sets the state back to provider assessing means" do
      expect(legal_aid_application.reload).to be_provider_assessing_means
    end

    it "redirects to the next page" do
      expect(response).to have_http_status(:redirect)
    end
  end
end
