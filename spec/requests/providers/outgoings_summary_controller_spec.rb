require "rails_helper"

RSpec.describe Providers::OutgoingsSummaryController do
  include Capybara

  let(:maintenance_out) { create(:transaction_type, :maintenance_out) }
  let(:rent_or_mortgage) { create(:transaction_type, :rent_or_mortgage) }

  let(:legal_aid_application) do
    application = create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine)

    create(
      :legal_aid_application_transaction_type,
      legal_aid_application: application,
      transaction_type: maintenance_out,
      owner_type: "Applicant",
      owner_id: application.applicant.id,
    )

    application
  end

  let(:provider) { legal_aid_application.provider }
  let(:login) { login_as provider }

  before do
    TransactionType.delete_all
    rent_or_mortgage
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

    it "displays a section for all debit transaction types linked to this application" do
      get_request

      expect(page).to have_css("ol li#maintenance_out h2", text: /maintenance/i)
    end

    it "does not display a section for transaction types not linked to this application" do
      get_request

      expect(page).to have_no_css("ol li", text: /housing/i)
    end

    context "when not all transaction types selected" do
      it "displays an Add additional outgoings types section" do
        get_request

        expect(page).to have_link("Add another type of regular payment")
      end
    end

    context "with all transaction types selected" do
      before do
        create(
          :legal_aid_application_transaction_type,
          legal_aid_application:,
          transaction_type: rent_or_mortgage,
          owner_type: "Applicant",
          owner_id: legal_aid_application.applicant.id,
        )
      end

      it "does not display an Add additional outgoing types section" do
        get_request

        expect(page).to have_no_link("Add another type of income")
      end
    end

    context "with assigned (by type) transactions" do
      let(:legal_aid_application) do
        application = create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine)
        bank_provider = create(:bank_provider, applicant: application.applicant)
        bank_account = create(:bank_account, bank_provider:)

        create(
          :legal_aid_application_transaction_type,
          legal_aid_application: application,
          transaction_type: maintenance_out,
          owner_type: "Applicant",
          owner_id: application.applicant.id,
        )

        create(:bank_transaction, :debit,
               transaction_type: maintenance_out,
               bank_account:,
               description: "Money to partner")

        application
      end

      it "displays bank transactions that have been categorised" do
        get_request

        within("li#maintenance_out") do
          expect(page).to have_content("Money to partner")
        end
      end

      it "displays a link to add more transaction of this type" do
        get_request
        path = providers_legal_aid_application_outgoing_transactions_path(legal_aid_application, transaction_type: maintenance_out.name)

        within("li#maintenance_out") do
          expect(page).to have_link("View statements and add transactions", href: path)
        end
      end
    end
  end

  describe "POST /providers/outgoings_summary" do
    subject(:post_request) { post providers_legal_aid_application_outgoings_summary_index_path(legal_aid_application), params: submit_button }

    let(:legal_aid_application) do
      application = create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine)
      bank_provider = create(:bank_provider, applicant: application.applicant)
      bank_account = create(:bank_account, bank_provider:)

      create(
        :legal_aid_application_transaction_type,
        legal_aid_application: application,
        transaction_type: maintenance_out,
        owner_type: "Applicant",
        owner_id: application.applicant.id,
      )

      create(:bank_transaction, :debit,
             transaction_type: maintenance_out,
             bank_account:,
             description: "Money to partner")

      application
    end

    let(:submit_button) { { continue_button: "Continue" } }

    before { post_request }

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
      subject(:post_request) { post providers_legal_aid_application_outgoings_summary_index_path(legal_aid_application), params: submit_button }

      let(:applicant) { create(:applicant) }
      let(:legal_aid_application) { create(:legal_aid_application, :with_non_passported_state_machine, applicant:, transaction_types: [rent_or_mortgage]) }
      let(:submit_button) { { continue_button: "Continue" } }

      before { post_request }

      it "renders successfully" do
        expect(response).to have_http_status(:ok)
      end

      it "returns errors" do
        expect(response.body).to include(I18n.t("activemodel.errors.models.legal_aid_application.attributes.uncategorised_bank_transactions.message"))
      end
    end
  end
end
