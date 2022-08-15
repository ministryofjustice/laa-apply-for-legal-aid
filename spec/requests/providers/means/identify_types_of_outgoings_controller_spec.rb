require "rails_helper"

RSpec.describe Providers::Means::IdentifyTypesOfOutgoingsController do
  let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine, :with_applicant }
  let(:provider) { legal_aid_application.provider }
  let(:login) { login_as provider }
  let!(:outgoing_types) { create_list :transaction_type, 3, :debit_with_standard_name }

  before { login }

  describe "GET /providers/applications/:legal_aid_application_id/means/identify_types_of_outgoing" do
    subject(:request) { get providers_legal_aid_application_means_identify_types_of_outgoing_path(legal_aid_application) }

    before { request }

    it "returns http success" do
      expect(response).to have_http_status(:ok)
    end

    it "displays the outgoing type labels" do
      outgoing_types.map(&:providers_label_name).each do |label|
        expect(unescaped_response_body).to include(label)
      end
      expect(unescaped_response_body).not_to include("translation missing")
    end

    it "does not display expanded explanation" do
      expect(unescaped_response_body).not_to match(I18n.t("shared.forms.types_of_outgoings_form.expanded_explanation.heading"))
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }

      it_behaves_like "a provider not authenticated"
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/means/identify_types_of_outgoing" do
    subject(:request) do
      patch(
        providers_legal_aid_application_means_identify_types_of_outgoing_path(legal_aid_application),
        params: params.merge(submit_button),
      )
    end

    let(:transaction_type_ids) { [] }
    let(:submit_button) { {} }
    let(:params) do
      {
        legal_aid_application: {
          transaction_type_ids:,
        },
      }
    end

    it "does not add transaction types to the application" do
      expect { request }.not_to change(LegalAidApplicationTransactionType, :count)
    end

    it "displays an error" do
      request
      expect(response.body).to match("govuk-error-summary")
      expect(unescaped_response_body).to match(I18n.t("providers.means.identify_types_of_outgoings.update.none_selected"))
      expect(unescaped_response_body).not_to include("translation missing")
    end

    it "returns http success" do
      request
      expect(response).to have_http_status(:ok)
    end

    context "when transaction types selected" do
      let(:transaction_type_ids) { outgoing_types.map(&:id) }

      it "adds transaction types to the application" do
        expect { request }.to change(LegalAidApplicationTransactionType, :count).by(outgoing_types.length)
        expect(legal_aid_application.reload.transaction_types).to match_array(outgoing_types)
      end

      it "sets no_debit_transaction_types_selected to false" do
        expect { request }.to change { legal_aid_application.reload.no_debit_transaction_types_selected }.to(false)
      end

      it "redirects to the means cash outgoings page" do
        request
        expect(response).to redirect_to(providers_legal_aid_application_means_cash_outgoing_path(legal_aid_application))
      end
    end

    context "when form submitted with Save as draft button" do
      let(:transaction_type_ids) { [] }
      let(:submit_button) { { draft_button: "Save as draft" } }

      it "redirects to the list of applications" do
        request
        expect(response).to redirect_to providers_legal_aid_applications_path
      end
    end

    context "when application has transaction types of other kind" do
      let(:other_transaction_type) { create :transaction_type, :credit }
      let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :with_non_passported_state_machine, transaction_types: [other_transaction_type] }

      it "does not remove existing transactions of other type" do
        expect { request }.not_to change { legal_aid_application.transaction_types.count }
      end

      it "does not delete transaction types" do
        expect { request }.not_to change(TransactionType, :count)
      end
    end

    context 'when "none selected" has been selected' do
      let(:params) { { legal_aid_application: { none_selected: "true" } } }

      it "does not add transaction types to the application" do
        expect { request }.not_to change(LegalAidApplicationTransactionType, :count)
      end

      it "sets no_debit_transaction_types_selected to true" do
        expect { request }.to change { legal_aid_application.reload.no_debit_transaction_types_selected }.to(true)
      end

      context "when application has transactions" do
        let(:legal_aid_application) do
          create :legal_aid_application, :with_applicant, :with_non_passported_state_machine, transaction_types: outgoing_types
        end

        it "removes transaction types from the application" do
          expect { request }.to change(LegalAidApplicationTransactionType, :count)
            .by(-outgoing_types.length)
        end
      end

      context "with previously selected income categories" do
        let(:income_types) { create_list :transaction_type, 3, :credit_with_standard_name }
        let!(:legal_aid_application) do
          create :legal_aid_application, :with_applicant,
                 :with_non_passported_state_machine, :applicant_entering_means, transaction_types: income_types
        end

        it "redirects to the income summary page" do
          request
          expect(response).to redirect_to(providers_legal_aid_application_income_summary_index_path(legal_aid_application))
        end
      end

      context "with no previously selected income categories" do
        let!(:legal_aid_application) do
          create :legal_aid_application, :with_applicant,
                 :with_non_passported_state_machine, :applicant_entering_means, transaction_types: []
        end

        it "redirects to the has dependants page" do
          request
          expect(response).to redirect_to(providers_legal_aid_application_means_has_dependants_path(legal_aid_application))
        end
      end
    end

    context "when the wrong transaction type is passed in" do
      let!(:income_types) { create_list :transaction_type, 3, :credit_with_standard_name }
      let(:transaction_type_ids) { income_types.map(&:id) }

      it "does not add the transaction types" do
        expect { request }.not_to change { legal_aid_application.transaction_types.count }
      end
    end

    context "when checking answers" do
      let(:legal_aid_application) do
        create :legal_aid_application,
               :with_non_passported_state_machine,
               :checking_non_passported_means
      end

      let(:params) { { legal_aid_application: { none_selected: "true" } } }

      context "with bank statement upload flow" do
        before do
          legal_aid_application.provider.permissions << Permission.find_or_create_by(role: "application.non_passported.bank_statement_upload.*")
          legal_aid_application.update!(provider_received_citizen_consent: false)
        end

        context "without debit transaction type" do
          before do
            legal_aid_application.transaction_types.debits.destroy_all
          end

          it "redirects to means_summaries" do
            request
            expect(response).to redirect_to(providers_legal_aid_application_means_summary_path(legal_aid_application))
          end
        end

        context "with debit transaction type" do
          let(:params) { { legal_aid_application: { transaction_type_ids: [create(:transaction_type, :debit).id] } } }

          it "redirects to cash_outgoings" do
            request
            expect(response).to redirect_to(providers_legal_aid_application_means_cash_outgoing_path(legal_aid_application))
          end
        end
      end

      context "without bank statement uploads" do
        before do
          legal_aid_application.provider.permissions.find_by(role: "application.non_passported.bank_statement_upload.*")&.destroy!
          legal_aid_application.update!(provider_received_citizen_consent: true)
        end

        context "without debit transaction types" do
          before do
            legal_aid_application.transaction_types.debits.destroy_all
          end

          it "redirects to income_summary" do
            request
            expect(response).to redirect_to(providers_legal_aid_application_outgoings_summary_index_path(legal_aid_application))
          end
        end

        context "with debit transaction types" do
          let(:params) { { legal_aid_application: { transaction_type_ids: [create(:transaction_type, :debit).id] } } }

          it "redirects to cash_outgoings" do
            request
            expect(response).to redirect_to(providers_legal_aid_application_means_cash_outgoing_path(legal_aid_application))
          end
        end
      end
    end

    context "when the provider is not authenticated" do
      before { request }

      let(:login) { nil }

      it_behaves_like "a provider not authenticated"
    end
  end
end
