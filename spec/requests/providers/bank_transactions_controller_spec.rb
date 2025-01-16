require "rails_helper"

RSpec.describe Providers::BankTransactionsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:provider) { legal_aid_application.provider }

  describe "PATCH providers/bank_transactions/:id/remove_transaction_type" do
    subject(:patch_request) do
      patch remove_transaction_type_providers_legal_aid_application_bank_transaction_path(legal_aid_application, bank_transaction)
    end

    let(:bank_transaction) do
      create(:bank_transaction,
             happened_at: 2.weeks.ago,
             description: "JOE BLOGGS",
             bank_account:,
             transaction_type:)
    end

    let!(:transaction_type) { create(:transaction_type) }
    let(:bank_provider) { create(:bank_provider, applicant: legal_aid_application.applicant) }
    let(:bank_account) { create(:bank_account, bank_provider:) }
    let(:login) { login_as provider }

    before { login }

    context "when the provider is not authenticated" do
      let(:login) { nil }

      before { patch_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      it "does not delete the transaction type" do
        expect { patch_request }.not_to change(TransactionType, :count)
      end

      it "removes the assocation with the transaction type" do
        expect { patch_request }.to change { bank_transaction.reload.transaction_type }.to(nil)
      end

      it "removes the meta data on the transaction" do
        bank_transaction.update!(meta_data: { code: "XXXX",
                                              label: "manually_chosen",
                                              name: "Maintenance In",
                                              category: "Maintenance In",
                                              selected_by: "Provider" })
        expect { patch_request }.to change { bank_transaction.reload.meta_data }.to(nil)
      end

      it "redirects back" do
        patch_request
        expect(response).to have_http_status(:redirect)
        follow_redirect!

        happened_at = I18n.l(bank_transaction.happened_at.to_date, format: :short_date)
        expect(response.body).to include("You removed transaction #{happened_at} JOE BLOGGS from the list")
      end

      context "with javascript enabled" do
        subject(:patch_request) do
          patch remove_transaction_type_providers_legal_aid_application_bank_transaction_path(legal_aid_application, bank_transaction), xhr: true
        end

        it "responds with status ok and flash message" do
          patch_request
          expect(response).to have_http_status(:ok)

          happened_at = I18n.l(bank_transaction.happened_at.to_date, format: :short_date)
          expect(response.body).to include("You removed transaction #{happened_at} JOE BLOGGS from the list")
        end
      end

      context "when bank_transaction does not belong to this application", :show_exceptions do
        let(:bank_account) { create(:bank_account) }

        it "does not remove the assocation with the transaction type" do
          expect { patch_request }.not_to change { bank_transaction.reload.transaction_type }
        end

        it "redirects to page_not_found" do
          patch_request
          expect(response).to render_template("errors/show/_page_not_found")
        end
      end
    end
  end
end
