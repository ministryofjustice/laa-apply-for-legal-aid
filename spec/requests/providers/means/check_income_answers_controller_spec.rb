require "rails_helper"

RSpec.describe Providers::Means::CheckIncomeAnswersController do
  include ActionView::Helpers::NumberHelper

  let(:provider) { create(:provider) }
  let(:applicant) { create(:applicant) }
  let(:pension) { create(:transaction_type, :pension) }
  let(:bank_provider) { create(:bank_provider, applicant:) }
  let(:bank_account) { create(:bank_account, bank_provider:) }
  let(:provider_received_citizen_consent) { true }

  let(:legal_aid_application) do
    create(:legal_aid_application,
           :with_negative_benefit_check_result,
           :with_non_passported_state_machine,
           :checking_means_income,
           :with_proceedings,
           :with_delegated_functions_on_proceedings,
           provider_received_citizen_consent:,
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
      let(:regular_transaction) { nil }

      before do
        login_as provider
        regular_transaction
        request
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "sets the state to checking means income" do
        expect(legal_aid_application.reload).to be_checking_means_income
      end

      context "when the client does truelayer journey" do
        it "displays the bank transaction data" do
          total_amount = bank_transactions.sum(&:amount)
          expect(total_amount).not_to be_zero
          expect(response.body).to include(ActiveSupport::NumberHelper.gds_number_to_currency(total_amount))
        end
      end

      context "when the client is uploading bank statements" do
        let(:provider_received_citizen_consent) { false }

        context "and has no incoming regular payments" do
          it "doesn't display the cash payments summary card" do
            expect(response.body).not_to include("Payments your client gets in cash")
          end

          it "shows only one line within 'Payments your client gets' summary card" do
            expect(response.body).to include("Payments received by your client")
          end
        end

        context "and has incoming regular payments" do
          let(:regular_transaction) { create(:regular_transaction, :friends_or_family, legal_aid_application:, owner_type: "Applicant") }

          it "displays the cash payments summary card" do
            expect(response.body).to include("Payments your client gets in cash")
          end

          it "shows only one line within 'Payments your client gets' summary card" do
            expect(response.body).to include("Financial help from friends or family")
          end
        end

        context "and has no outgoing regular payments" do
          it "doesn't display the cash payments summary card" do
            expect(response.body).not_to include("Payments your client pays in cash")
          end

          it "shows only one line within 'Payments your client pays' summary card" do
            expect(response.body).to include("Payments paid by your client")
          end
        end

        context "and has outgoing regular payments" do
          let(:regular_transaction) { create(:regular_transaction, :maintenance_out, legal_aid_application:, owner_type: "Applicant") }

          it "displays the cash payments summary card" do
            expect(response.body).to include("Payments your client pays in cash")
          end

          it "shows only one line within 'Payments your client pays' summary card" do
            expect(response.body).to include("Maintenance payments to a former partner")
          end
        end
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
