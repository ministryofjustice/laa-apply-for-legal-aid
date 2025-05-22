require "rails_helper"

RSpec.describe Providers::IncomeSummaryController do
  include Capybara

  let!(:benefits) { create(:transaction_type, :credit, name: "benefits") }
  let!(:maintenance_in) { create(:transaction_type, :credit, name: "maintenance_in") }

  let(:legal_aid_application) do
    application = create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine)

    create(
      :legal_aid_application_transaction_type,
      legal_aid_application: application,
      transaction_type: benefits,
      owner_type: "Applicant",
      owner_id: application.applicant.id,
    )

    application
  end

  let(:provider) { legal_aid_application.provider }
  let(:login) { login_as provider }

  before do
    login
  end

  describe "GET /providers/income_summary" do
    subject(:get_request) { get providers_legal_aid_application_income_summary_index_path(legal_aid_application) }

    it "returns http success" do
      get_request
      expect(response).to have_http_status(:ok)
    end

    it "displays a section for all credit transaction types linked to this application" do
      get_request

      expect(page).to have_css("ol li#benefits h2", text: /benefits/i)
    end

    it "does not display a section for transaction types not linked to this application" do
      get_request

      expect(page).to have_no_css("ol li", text: /maintenance/i)
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }

      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when not all transaction types selected" do
      it "displays an Add additional income types section" do
        get_request

        expect(page).to have_link("Add another type of income")
      end
    end

    context "when all possible transaction types selected" do
      before do
        create(
          :legal_aid_application_transaction_type,
          legal_aid_application:,
          transaction_type: maintenance_in,
          owner_type: "Applicant",
          owner_id: legal_aid_application.applicant.id,
        )
      end

      it "does not display an Add additional income types section" do
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
          transaction_type: maintenance_in,
          owner_type: "Applicant",
          owner_id: application.applicant.id,
        )

        create(:bank_transaction, :credit,
               transaction_type: maintenance_in,
               bank_account:,
               description: "Money from Dad")

        application
      end

      it "displays bank transactions that have been categorised" do
        get_request

        within("li#maintenance_in") do
          expect(page).to have_content("Money from Dad")
        end
      end

      it "displays a link to add more transaction of this type" do
        get_request
        path = providers_legal_aid_application_incoming_transactions_path(legal_aid_application, transaction_type: maintenance_in.name)

        within("li#maintenance_in") do
          expect(page).to have_link("View statements and add transactions", href: path)
        end
      end
    end
  end

  describe "POST /providers/income_summary" do
    subject(:post_request) { post providers_legal_aid_application_income_summary_index_path(legal_aid_application), params: submit_button }

    let!(:pension) { create(:transaction_type, :credit, name: "pension") }

    let(:legal_aid_application) do
      application = create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine)

      create(
        :legal_aid_application_transaction_type,
        legal_aid_application: application,
        transaction_type: pension,
        owner_type: "Applicant",
        owner_id: application.applicant.id,
      )

      application
    end

    let(:submit_button) { { continue_button: "Continue" } }

    before { post_request }

    context "when no outgoings categories previously selected" do
      let(:legal_aid_application) do
        create(:legal_aid_application,
               :with_applicant,
               :with_non_passported_state_machine,
               :applicant_entering_means,
               transaction_types: [])
      end

      it "redirects to the next page" do
        expect(response).to have_http_status(:redirect)
      end

      context "and there is a partner with no contrary interest" do
        let(:legal_aid_application) do
          create(:legal_aid_application,
                 :with_applicant_and_partner,
                 :with_non_passported_state_machine,
                 :applicant_entering_means,
                 transaction_types: [])
        end

        it "redirects to the next page" do
          expect(response).to have_http_status(:redirect)
        end
      end
    end

    context "when outgoings categories are shown" do
      let!(:maintenance_out) { create(:transaction_type, :debit, name: "maintenance_out") }

      let(:legal_aid_application) do
        create(:legal_aid_application,
               :with_applicant,
               :with_non_passported_state_machine,
               :applicant_entering_means,
               transaction_types: [maintenance_out])
      end

      it "redirects to the next page" do
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }

      it_behaves_like "a provider not authenticated"
    end

    context "when the Form is submitted with the Save as draft button" do
      let(:submit_button) { { draft_button: "Save as draft" } }

      it "redirects to the list of applications" do
        expect(response).to redirect_to in_progress_providers_legal_aid_applications_path
      end
    end

    context "when the transaction type category has no bank transactions" do
      subject(:post_request) { post providers_legal_aid_application_income_summary_index_path(legal_aid_application), params: submit_button }

      let(:applicant) { create(:applicant) }
      let(:legal_aid_application) { create(:legal_aid_application, :with_non_passported_state_machine, applicant:, transaction_types: [pension]) }
      let(:submit_button) { { continue_button: "Continue" } }

      before { post_request }

      it "renders successfully" do
        expect(response).to have_http_status(:ok)
      end

      it "returns errors" do
        expect(response.body).to include(I18n.t("activemodel.errors.models.legal_aid_application.attributes.uncategorised_bank_transactions.message"))
      end
    end

    context "when no disregarded benefits are categorised" do
      let(:excluded_benefits) { create(:transaction_type, :credit, name: "excluded_benefits") }
      let(:legal_aid_application) { create(:legal_aid_application, :with_non_passported_state_machine, applicant:, transaction_types: [excluded_benefits]) }
      let(:applicant) { create(:applicant) }

      it "does not return an error" do
        expect(response.body).not_to include(I18n.t("activemodel.errors.models.legal_aid_application.attributes.uncategorised_bank_transactions.message"))
      end
    end
  end
end
