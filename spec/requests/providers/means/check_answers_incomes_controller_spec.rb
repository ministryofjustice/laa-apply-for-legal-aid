require "rails_helper"

RSpec.describe Providers::Means::CheckAnswersIncomesController do
  include ActionView::Helpers::NumberHelper
  let(:provider) { create(:provider) }
  let(:applicant) { create(:applicant) }
  let(:transaction_type) { create(:transaction_type) }
  let(:bank_provider) { create(:bank_provider, applicant:) }
  let(:bank_account) { create(:bank_account, bank_provider:) }
  let(:legal_aid_application) do
    create(:legal_aid_application,
           :with_negative_benefit_check_result,
           :with_non_passported_state_machine,
           :provider_assessing_means,
           :with_proceedings,
           :with_delegated_functions_on_proceedings,
           df_options: { DA001: Time.zone.today },
           applicant:,
           provider:,
           transaction_types: [transaction_type])
  end

  describe "GET /providers/applications/:legal_aid_application_id/means/check_answers_income" do
    subject(:request) { get providers_legal_aid_application_means_check_answers_income_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      let(:bank_transactions) { create_list(:bank_transaction, 3, transaction_type:, bank_account:) }

      before do
        login_as provider
        request
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays the bank transaction data" do
        total_amount = bank_transactions.sum(&:amount)
        expect(total_amount).not_to be_zero
        expect(response.body).to include(ActiveSupport::NumberHelper.gds_number_to_currency(total_amount))
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/means/check_answers_income" do
    subject(:request) { patch providers_legal_aid_application_means_check_answers_income_path(legal_aid_application), params: }

    it "redirects to the own homes page" do
      expect(response).to redirect_to(providers_legal_aid_application_means_own_home_path(legal_aid_application))
    end
  end
end
