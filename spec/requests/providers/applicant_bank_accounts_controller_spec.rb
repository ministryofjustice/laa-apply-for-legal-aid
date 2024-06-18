require "rails_helper"

RSpec.describe Providers::ApplicantBankAccountsController do
  let(:applicant) { create(:applicant) }
  let!(:bank_provider) { create(:bank_provider, applicant:) }
  let!(:bank_account) { create(:bank_account, bank_provider:) }
  let(:legal_aid_application) { create(:legal_aid_application, :with_non_passported_state_machine, :with_savings_amount, applicant:) }
  let(:application_id) { legal_aid_application.id }
  let!(:provider) { legal_aid_application.provider }

  describe "GET providers/:application_id/applicant_bank_account" do
    subject(:get_request) { get providers_legal_aid_application_applicant_bank_account_path(legal_aid_application.id) }

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
        expect(response).to have_http_status(:success)
      end

      it "displays the correct page content" do
        expect(unescaped_response_body).to include(I18n.t("providers.applicant_bank_accounts.show.heading"))
        expect(unescaped_response_body).to include(I18n.t("providers.applicant_bank_accounts.show.offline_savings_accounts"))
      end

      it "shows the client bank account name and balance" do
        get_request
        expect(unescaped_response_body).to include(bank_provider.name)
        expect(response.body).to include(bank_account.balance.to_fs(:delimited))
      end
    end
  end

  describe "PATCH /providers/applications/:application_id/applicant_bank_account" do
    subject(:patch_request) do
      patch(
        "/providers/applications/#{application_id}/applicant_bank_account",
        params:,
      )
    end

    let(:applicant_bank_account) { "false" }
    let(:offline_savings_accounts) { rand(1...1_000_000.0).round(2) }
    let(:params) do
      {
        savings_amount: {
          applicant_bank_account:,
          offline_savings_accounts:,
        },
      }
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        patch_request
      end

      context "when neither option is chosen" do
        let(:applicant_bank_account) { nil }

        it "shows an error" do
          expect(unescaped_response_body).to include(I18n.t("errors.applicant_bank_accounts.blank"))
        end
      end

      context "when the NO option is chosen" do
        let(:applicant_bank_account) { "false" }

        it "redirects to the next page" do
          expect(response).to have_http_status(:redirect)
        end

        context "when savings amount is not nil" do
          let(:offline_savings_accounts) { "" }

          it "resets the account balance to nil for offline savings account" do
            expect(legal_aid_application.reload.savings_amount.offline_savings_accounts).to be_nil
          end
        end
      end

      context "when the YES option is chosen" do
        let(:applicant_bank_account) { "true" }

        context "when no amount is entered" do
          let(:offline_savings_accounts) { "" }

          it "displays the correct error" do
            expect(unescaped_response_body).to include(I18n.t("activemodel.errors.models.savings_amount.attributes.offline_savings_accounts.blank"))
          end
        end

        context "when an invalid input is entered" do
          let(:offline_savings_accounts) { "abc" }

          it "displays the correct error" do
            expect(unescaped_response_body).to include(I18n.t("activemodel.errors.models.savings_amount.attributes.offline_savings_accounts.not_a_number"))
          end
        end

        context "when a valid savings amount is entered" do
          let(:offline_savings_accounts) { rand(1...1_000_000.0).round(2) }

          it "updates the savings amount" do
            expect(legal_aid_application.reload.savings_amount.offline_savings_accounts).to eq(BigDecimal(offline_savings_accounts.to_fs))
          end

          context "and the applicant has a partner" do
            let(:applicant) { create(:applicant, :with_partner, partner_has_contrary_interest: false) }

            it "redirects to the next page" do
              expect(response).to have_http_status(:redirect)
            end
          end

          context "and there is no partner" do
            it "redirects to the next page" do
              expect(response).to have_http_status(:redirect)
            end
          end
        end
      end
    end
  end
end
