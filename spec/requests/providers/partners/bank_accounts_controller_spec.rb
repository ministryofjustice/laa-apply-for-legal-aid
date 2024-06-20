require "rails_helper"

RSpec.describe Providers::Partners::BankAccountsController do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:provider) { legal_aid_application.provider }
  let(:savings_amount) { legal_aid_application.savings_amount }

  before { login_as provider }

  describe "GET /providers/applications/:legal_aid_application_id/partners/bank_accounts" do
    before do
      get providers_legal_aid_application_partners_bank_accounts_path(legal_aid_application)
    end

    it "renders page with expected heading" do
      expect(response).to have_http_status(:ok)
      expect(page).to have_css("h1", text: "Which bank accounts does the partner have?")
    end
  end

  describe "PATCH /providers/applications/:application_id/partners/bank_accounts" do
    subject(:patch_request) { patch providers_legal_aid_application_partners_bank_accounts_path(legal_aid_application), params: }

    let(:partner_offline_current_accounts) { rand(1...1_000_000.0).round(2).to_s }
    let(:check_box_partner_offline_current_accounts) { "true" }

    let(:partner_offline_savings_accounts) { rand(1...1_000_000.0).round(2).to_s }
    let(:check_box_partner_offline_savings_accounts) { "true" }

    context "when one of the values is submitted" do
      let(:params) do
        {
          savings_amount: {
            partner_offline_current_accounts:,
            check_box_partner_offline_current_accounts:,
          },
        }
      end

      it "updates the offline_current_accounts amount" do
        patch_request
        expect(savings_amount.reload.partner_offline_current_accounts.to_s).to eql partner_offline_current_accounts
        expect(savings_amount.reload.no_partner_account_selected.to_s).to eq ""
      end

      it "redirects to the next step in the journey" do
        patch_request
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when both of the values are submitted" do
      let(:params) do
        {
          savings_amount: {
            partner_offline_current_accounts:,
            check_box_partner_offline_current_accounts:,
            partner_offline_savings_accounts:,
            check_box_partner_offline_savings_accounts:,
          },
        }
      end

      it "updates the offline_current_accounts amount" do
        patch_request
        expect(savings_amount.reload.partner_offline_current_accounts.to_s).to eql partner_offline_current_accounts
        expect(savings_amount.reload.partner_offline_savings_accounts.to_s).to eql partner_offline_savings_accounts
        expect(savings_amount.reload.no_partner_account_selected.to_s).to eq ""
      end

      it "redirects to the next step in the journey" do
        patch_request
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when the none option is submitted" do
      let(:params) do
        {
          savings_amount: {
            no_partner_account_selected: "true",
          },
        }
      end

      it "updates the offline_current_accounts amount" do
        patch_request
        expect(savings_amount.reload.partner_offline_current_accounts.to_s).to eq ""
        expect(savings_amount.reload.partner_offline_savings_accounts.to_s).to eq ""
        expect(savings_amount.reload.no_partner_account_selected.to_s).to eq "true"
      end

      it "redirects to the next step in the journey" do
        patch_request
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when the user submits with no option chosen" do
      let(:params) do
        {
          savings_amount: {
            partner_offline_current_accounts: "",
          },
        }
      end

      it "renders the current page with an error" do
        patch_request
        expect(response).to have_http_status(:ok)
        expect(page).to have_css("p", class: "govuk-error-message", text: "Select if the partner has current or savings accounts")
      end
    end
  end
end
