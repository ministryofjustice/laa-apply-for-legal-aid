require "rails_helper"

RSpec.describe Providers::Partners::CashIncomesController do
  before do
    create(:transaction_type, :benefits)
    legal_aid_application.set_transaction_period
  end

  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_partner, :with_passported_state_machine, :provider_entering_means) }
  let(:next_flow_step) { flow_forward_path }
  let(:provider) { legal_aid_application.provider }

  let(:nothing_selected) do
    {
      aggregated_cash_income: {
        check_box_benefits: "",
        none_selected: "true",
      },
    }
  end

  let(:valid_params) do
    {
      aggregated_cash_income: {
        check_box_benefits: "true",
        benefits1: "1",
        benefits2: "2",
        benefits3: "3",
        none_selected: "",
      },
    }
  end

  let(:invalid_params) do
    {
      aggregated_cash_income: {
        check_box_benefits: "true",
        benefits1: "1.11111",
        benefits2: "$",
        benefits3: "-1",
        check_box_maintenance_in: "true",
        maintenance_in1: "",
        maintenance_in2: "",
        maintenance_in3: "",
      },
    }
  end

  describe "GET /providers/applications/:legal_aid_application_id/partners/cash_income" do
    subject(:request) { get providers_legal_aid_application_partners_cash_income_path(legal_aid_application) }

    before { login_as provider }

    it "shows the page" do
      request
      expect(response.body).to include(I18n.t("providers.partners.cash_incomes.show.page_title"))
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/partners/cash_income" do
    subject(:request) { patch providers_legal_aid_application_partners_cash_income_path(legal_aid_application), params: }

    before { login_as provider }

    context "with valid params" do
      let(:params) { valid_params }

      it "redirects to the next page" do
        request
        expect(response).to have_http_status(:redirect)
      end

      it "updates the model attribute for no cash income to false" do
        expect { request }.to change { legal_aid_application.partner.reload.no_cash_income }.from(nil).to(false)
      end

      it "sets the applicant as owner" do
        request
        expect(legal_aid_application.cash_transactions.first).to have_attributes(
          {
            owner_type: "Partner",
            owner_id: legal_aid_application.partner.id,
          },
        )
      end
    end

    context "with nothing selected" do
      let(:params) { nothing_selected }

      it "redirects to the next page" do
        request
        expect(response).to have_http_status(:redirect)
      end

      it "updates the model attribute for no cash income to true" do
        expect { request }.to change { legal_aid_application.partner.reload.no_cash_income }.from(nil).to(true)
      end
    end

    context "with invalid params" do
      let(:params) { invalid_params }

      before { request }

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "shows an error for no amount entered" do
        expect(response.body).to include(I18n.t("errors.aggregated_cash_income.blank", category: "maintenance",
                                                                                       month: (Time.zone.today - 1.month).strftime("%B")))
      end

      it "shows an error for an invalid amount" do
        expect(response.body).to include(I18n.t("errors.aggregated_cash_income.invalid_type", category: "maintenance",
                                                                                              month: (Time.zone.today - 1.month).strftime("%B")))
      end

      it "shows an error for a negtive amount" do
        expect(response.body).to include(I18n.t("errors.aggregated_cash_income.negative"))
      end

      it "shows an error for an amount with too many decimals" do
        expect(response.body).to include(I18n.t("errors.aggregated_cash_income.too_many_decimals", category: "maintenance",
                                                                                                   month: (Time.zone.today - 1.month).strftime("%B")))
      end
    end

    context "with no params" do
      let(:params) { { aggregated_cash_income: { check_box_benefits: "" } } }

      before { request }

      it "shows an error if nothing selected" do
        expect(response.body).to include(I18n.t("activemodel.errors.models.aggregated_cash_income.credits.attributes.cash_income.blank"))
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

      context "with bank statement upload flow" do
        before do
          legal_aid_application.provider.permissions << Permission.find_or_create_by(role: "application.non_passported.bank_statement_upload.*")
          legal_aid_application.update!(provider_received_citizen_consent: false)
        end

        it "redirects to the next page" do
          request
          expect(response).to have_http_status(:redirect)
        end
      end
    end
  end
end
