require "rails_helper"

RSpec.describe Providers::OutgoingsSummaryController do
  let(:transaction_type) { create(:transaction_type, :debit_with_standard_name) }
  let(:other_transaction_type) { create(:transaction_type, :debit_with_standard_name) }
  let(:legal_aid_application) do
    create(
      :legal_aid_application,
      :with_applicant,
      :with_transaction_period,
      :with_non_passported_state_machine,
      transaction_types: [transaction_type],
    )
  end
  let(:provider) { legal_aid_application.provider }
  let(:login) { login_as provider }

  before do
    create(:transaction_type, :debit, name: "legal_aid")
    TransactionType.delete_all
    other_transaction_type
    login
  end

  describe "GET /providers/outgoings_summary" do
    subject(:get_request) { get providers_legal_aid_application_outgoings_summary_index_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      let(:login) { nil }

      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    it "returns http success" do
      get_request
      expect(response).to have_http_status(:ok)
    end

    it "displays a section for all transaction types linked to this application" do
      get_request
      name = transaction_type.name
      legend = I18n.t("transaction_types.names.providers.#{name}")
      expect(parsed_response_body.css("ol li##{name}").text).to match(/#{legend}/)
    end

    it "does not display a section for transaction types not linked to this application" do
      get_request
      expect(parsed_response_body.css("ol li h2#outgoing-type-#{other_transaction_type.name}").size).to be_zero
    end

    context "without all transaction types selected" do
      it "displays an Add additional outgoings types section" do
        get_request
        expect(response.body).to include("Add another type of regular payment")
      end
    end

    context "with all transaction types selected" do
      let(:legal_aid_application) do
        create(
          :legal_aid_application,
          :with_applicant,
          :with_non_passported_state_machine,
          transaction_types: [transaction_type, other_transaction_type],
        )
      end

      it "does not display an Add additional outgoing types section" do
        get providers_legal_aid_application_outgoings_summary_index_path(legal_aid_application)
        expect(response.body).not_to include("Add another type of regular payment")
      end
    end

    context "with assigned (by type) transactions" do
      let(:applicant) { create(:applicant) }
      let(:bank_provider) { create(:bank_provider, applicant:) }
      let(:bank_account) { create(:bank_account, bank_provider:) }
      let(:transaction_type) { create(:transaction_type, :debit) }
      let!(:bank_transaction) { create(:bank_transaction, :debit, transaction_type:, bank_account:) }
      let(:legal_aid_application) { create(:legal_aid_application, :with_non_passported_state_machine, applicant:, transaction_types: [transaction_type]) }

      it "displays bank transaction" do
        get_request
        expect(legal_aid_application.bank_transactions).to include(bank_transaction)
        expect(response.body).to include(bank_transaction.description)
      end

      it "displays a link to add more transaction of this type" do
        get_request
        path = providers_legal_aid_application_outgoing_transactions_path(legal_aid_application, transaction_type: transaction_type.name)
        expect(response.body).to include(path)
      end
    end
  end

  describe "POST /providers/outgoings_summary" do
    let(:applicant) { create(:applicant) }
    let(:bank_provider) { create(:bank_provider, applicant:) }
    let(:bank_account) { create(:bank_account, bank_provider:) }
    let(:bank_transaction) { create(:bank_transaction, :debit, transaction_type:, bank_account:) }
    let(:legal_aid_application) { create(:legal_aid_application, :with_non_passported_state_machine, applicant:, transaction_types: [transaction_type]) }

    let(:submit_button) { { continue_button: "Continue" } }

    before do
      bank_transaction
      post providers_legal_aid_application_outgoings_summary_index_path(legal_aid_application), params: submit_button
    end

    it "redirects to the next page" do
      expect(response).to have_http_status(:redirect)
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }

      it_behaves_like "a provider not authenticated"
    end

    context "when Form submitted with Save as draft button" do
      let(:submit_button) { { draft_button: "Save as draft" } }

      it "redirects to the next page" do
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when the transaction type category has no bank transactions" do
      let(:bank_transaction) { create(:bank_transaction, :debit, transaction_type: nil, bank_account:) }

      it "renders successfully" do
        expect(response).to have_http_status(:ok)
      end

      it "returns errors" do
        expect(response.body).to include(I18n.t("activemodel.errors.models.legal_aid_application.attributes.uncategorised_bank_transactions.message"))
      end
    end
  end
end
