require "rails_helper"

RSpec.describe Providers::Partners::CashOutgoingsController do
  before do
    create(:transaction_type, :child_care)
    legal_aid_application.set_transaction_period
  end

  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_partner, :with_non_passported_state_machine, :applicant_entering_means) }
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

  describe "GET /providers/applications/:legal_aid_application_id/partners/cash_outgoings" do
    subject(:request) { get providers_legal_aid_application_partners_cash_outgoing_path(legal_aid_application) }

    before { login_as provider }

    it "render applicable page title" do
      request
      expect(response.body).to include("Select payments the partner pays in cash")
    end
  end

  describe "PATCH providers/applications/:legal_aid_application_id/partners/cash_outgoing" do
    subject(:request) { patch providers_legal_aid_application_partners_cash_outgoing_path(legal_aid_application), params: }

    let(:transaction_type) { create(:transaction_type, :rent_or_mortgage) }
    let(:partner_transaction_type) do
      create(:legal_aid_application_transaction_type,
             legal_aid_application_id: legal_aid_application.id,
             transaction_type_id: transaction_type.id,
             owner_type: "Partner", owner_id: legal_aid_application.partner.id)
    end
    let(:applicant_transaction_type) do
      create(:legal_aid_application_transaction_type,
             legal_aid_application_id: legal_aid_application.id,
             transaction_type_id: transaction_type.id,
             owner_type: "Applicant", owner_id: legal_aid_application.applicant.id)
    end

    before { login_as provider }

    context "with valid params" do
      let(:params) { valid_params }

      it "updates the model attribute for no cash outgoings to false" do
        expect { request }.to change { legal_aid_application.partner.reload.no_cash_outgoings }.from(nil).to(false)
      end

      context "with no housing payments selected for either applicant or partner" do
        it "redirects to the next page" do
          request
          expect(response).to have_http_status(:redirect)
        end
      end

      context "when partner has rent or mortgage as an outgoing category" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_partner, :with_non_passported_state_machine, :applicant_entering_means, transaction_types: [transaction_type]) }

        before do
          legal_aid_application.legal_aid_application_transaction_types << partner_transaction_type
        end

        it "redirects to the next page" do
          request
          expect(response).to have_http_status(:redirect)
        end
      end

      context "when applicant did manual bank upload and selected housing payments" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_partner, :with_non_passported_state_machine, :applicant_entering_means, transaction_types: [transaction_type]) }

        before do
          legal_aid_application.provider.permissions << Permission.find_or_create_by(role: "application.non_passported.bank_statement_upload.*")
          legal_aid_application.update!(provider_received_citizen_consent: false)
          legal_aid_application.legal_aid_application_transaction_types << applicant_transaction_type
        end

        it "redirects to the next page" do
          request
          expect(response).to have_http_status(:redirect)
        end
      end
    end

    context "with nothing selected" do
      let(:params) { nothing_selected_params }

      it "updates the model attribute for no cash outgoings to true" do
        expect { request }.to change { legal_aid_application.partner.reload.no_cash_outgoings }.from(nil).to(true)
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
               :with_applicant_and_partner,
               :with_non_passported_state_machine,
               :checking_means_income)
      end

      let(:params) { valid_params }

      context "when using bank statement upload journey" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_partner, :with_non_passported_state_machine, :applicant_entering_means, transaction_types: [transaction_type]) }

        before do
          legal_aid_application.provider.permissions << Permission.find_or_create_by(role: "application.non_passported.bank_statement_upload.*")
          legal_aid_application.update!(provider_received_citizen_consent: false)
        end

        context "and there are applicant housing payments" do
          before do
            legal_aid_application.legal_aid_application_transaction_types << applicant_transaction_type
          end

          it "redirects to the next page" do
            request
            expect(response).to have_http_status(:redirect)
          end
        end

        context "and there are partner housing payments" do
          before do
            legal_aid_application.legal_aid_application_transaction_types << partner_transaction_type
          end

          it "redirects to the next page" do
            request
            expect(response).to have_http_status(:redirect)
          end
        end

        context "but there are no housing payments" do
          it "redirects to the next page" do
            request
            expect(response).to have_http_status(:redirect)
          end
        end
      end

      context "when using truelayer journey" do
        before do
          legal_aid_application.provider.permissions.find_by(role: "application.non_passported.bank_statement_upload.*")&.destroy!
          legal_aid_application.update!(provider_received_citizen_consent: true)
        end

        it "redirects to the next page" do
          request
          expect(response).to have_http_status(:redirect)
        end
      end
    end
  end
end
