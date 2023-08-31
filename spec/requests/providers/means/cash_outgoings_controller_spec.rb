require "rails_helper"

RSpec.describe Providers::Means::CashOutgoingsController do
  before do
    create(:transaction_type, :child_care)
    legal_aid_application.set_transaction_period
  end

  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine, :applicant_entering_means) }
  let(:provider) { legal_aid_application.provider }

  let(:valid_params) do
    {
      aggregated_cash_outgoings: {
        check_box_child_care: "true",
        child_care1: "1",
        child_care2: "2",
        child_care3: "3",
        none_selected: "",
      },
    }
  end

  let(:nothing_selected_params) do
    {
      aggregated_cash_outgoings: {
        check_box_child_care: "",
        none_selected: "true",
      },
    }
  end

  let(:invalid_params) do
    {
      aggregated_cash_outgoings: {
        check_box_child_care: "true",
        child_care1: "1.11111",
        child_care2: "$",
        child_care3: "-1",
        check_box_maintenance_out: "true",
        maintenance_out1: "",
        maintenance_out2: "",
        maintenance_out3: "",
      },
    }
  end

  describe "GET /providers/applications/:legal_aid_application_id/means/cash_outgoings" do
    subject(:request) { get providers_legal_aid_application_means_cash_outgoing_path(legal_aid_application) }

    before { login_as provider }

    it "render applicable page title" do
      request
      expect(response.body).to include("Select payments your client pays in cash")
    end
  end

  describe "PATCH providers/applications/:legal_aid_application_id/means/cash_outgoing" do
    subject(:request) { patch providers_legal_aid_application_means_cash_outgoing_path(legal_aid_application), params: }

    before { login_as provider }

    context "with valid params" do
      let(:params) { valid_params }

      it "updates the model attribute for no cash outgoings to false" do
        expect { request }.to change { legal_aid_application.reload.no_cash_outgoings }.from(nil).to(false)
      end

      context "without bank statement upload flow" do
        before do
          legal_aid_application.provider.permissions.find_by(role: "application.non_passported.bank_statement_upload.*")&.destroy!
          legal_aid_application.update!(provider_received_citizen_consent: true)
        end

        context "with income categories" do
          let(:income_types) { create_list(:transaction_type, 3, :credit_with_standard_name) }
          let!(:legal_aid_application) do
            create(:legal_aid_application, :with_applicant,
                   :with_non_passported_state_machine, :applicant_entering_means, transaction_types: income_types)
          end

          it "redirects to income summary page" do
            request
            expect(response).to redirect_to(providers_legal_aid_application_income_summary_index_path(legal_aid_application))
          end

          it "sets the applicant as owner" do
            request
            expect(legal_aid_application.cash_transactions.first).to have_attributes(
              {
                owner_type: "Applicant",
                owner_id: legal_aid_application.applicant.id,
              },
            )
          end
        end

        context "with outgoings categories but no income categories" do
          let(:outgoings_categories) { create_list(:transaction_type, 3, :debit_with_standard_name) }
          let(:legal_aid_application) do
            create(:legal_aid_application,
                   :with_applicant,
                   :with_non_passported_state_machine,
                   :applicant_entering_means,
                   transaction_types: outgoings_categories)
          end

          it "redirects to the outgoings summary page" do
            request
            expect(response).to redirect_to(providers_legal_aid_application_outgoings_summary_index_path(legal_aid_application))
          end
        end

        context "without income or outgoings categories" do
          let(:params) { nothing_selected_params }
          let(:legal_aid_application) do
            create(:legal_aid_application,
                   :with_applicant,
                   :with_non_passported_state_machine,
                   :applicant_entering_means,
                   transaction_types: [])
          end

          context "and has no partner" do
            it "redirects to the dependants page" do
              request
              expect(response).to redirect_to(providers_legal_aid_application_means_has_dependants_path(legal_aid_application))
            end
          end

          context "and has partner with no contrary interest" do
            let(:legal_aid_application) do
              create(:legal_aid_application,
                     :with_applicant_and_partner,
                     :with_non_passported_state_machine,
                     :applicant_entering_means,
                     transaction_types: [])
            end

            it "redirects to the partner about financial means page" do
              request
              expect(response).to redirect_to(providers_legal_aid_application_partners_about_financial_means_path(legal_aid_application))
            end
          end
        end
      end

      context "with bank statement upload flow" do
        before do
          legal_aid_application.provider.permissions << Permission.find_or_create_by(role: "application.non_passported.bank_statement_upload.*")
          legal_aid_application.update!(provider_received_citizen_consent: false)
        end

        context "with income and outgoing categories" do
          let(:legal_aid_application) do
            create(:legal_aid_application, :with_applicant,
                   :with_non_passported_state_machine,
                   :applicant_entering_means,
                   transaction_types:)
          end

          let(:transaction_types) { [create(:transaction_type, :credit_with_standard_name), create(:transaction_type, :debit_with_standard_name)] }

          it "redirects to has dependants page" do
            request
            expect(response).to redirect_to(providers_legal_aid_application_means_has_dependants_path(legal_aid_application))
          end
        end

        context "without income or outgoing categories" do
          let(:legal_aid_application) do
            create(:legal_aid_application, :with_applicant,
                   :with_non_passported_state_machine,
                   :applicant_entering_means,
                   transaction_types: [])
          end

          it "redirects to has dependants page" do
            request
            expect(response).to redirect_to(providers_legal_aid_application_means_has_dependants_path(legal_aid_application))
          end
        end
      end
    end

    context "with nothing selected" do
      let(:params) { nothing_selected_params }

      it "updates the model attribute for no cash outgoings to true" do
        expect { request }.to change { legal_aid_application.reload.no_cash_outgoings }.from(nil).to(true)
      end
    end

    context "with invalid params" do
      let(:params) { invalid_params }

      before { request }

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "shows an error for no amount entered" do
        expected_month = (Time.zone.today - 1.month).strftime("%B")
        expect(response.body).to include(I18n.t("errors.aggregated_cash_outgoings.blank", category: "in maintenance", month: expected_month))
      end

      it "shows an error for an invalid type" do
        expect(response.body).to include(I18n.t("errors.aggregated_cash_outgoings.invalid_type"))
      end

      it "shows an error for a negtive amount" do
        expect(response.body).to include(I18n.t("errors.aggregated_cash_outgoings.negative"))
      end

      it "shows an error for an amount with too many decimals" do
        expect(response.body).to include(I18n.t("errors.aggregated_cash_outgoings.too_many_decimals"))
      end
    end

    context "with no params" do
      let(:params) { { aggregated_cash_outgoings: { check_box_child_care: "" } } }

      it "shows an error if nothing selected" do
        request
        expect(response.body).to include(I18n.t("activemodel.errors.models.aggregated_cash_outgoings.debits.attributes.cash_outgoings.blank"))
      end
    end

    context "when checking answers" do
      let(:legal_aid_application) do
        create(:legal_aid_application,
               :with_applicant,
               :with_non_passported_state_machine,
               :checking_means_income)
      end

      let(:params) { valid_params }

      context "with bank statement upload flow" do
        before do
          legal_aid_application.provider.permissions << Permission.find_or_create_by(role: "application.non_passported.bank_statement_upload.*")
          legal_aid_application.update!(provider_received_citizen_consent: false)
        end

        it "redirects to checking answers income" do
          request
          expect(response).to redirect_to(providers_legal_aid_application_means_check_income_answers_path(legal_aid_application))
        end
      end

      context "without bank statement uploads" do
        before do
          legal_aid_application.provider.permissions.find_by(role: "application.non_passported.bank_statement_upload.*")&.destroy!
          legal_aid_application.update!(provider_received_citizen_consent: true)
        end

        it "redirects to income_summary" do
          request
          expect(response).to redirect_to(providers_legal_aid_application_outgoings_summary_index_path(legal_aid_application))
        end
      end
    end
  end
end
