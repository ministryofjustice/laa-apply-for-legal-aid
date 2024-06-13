require "rails_helper"

RSpec.describe Providers::Means::RegularOutgoingsController do
  let(:legal_aid_application) do
    create(:legal_aid_application,
           :with_applicant,
           :with_non_passported_state_machine,
           no_debit_transaction_types_selected: true)
  end
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/means/regular_outgoings" do
    subject(:request) { get providers_legal_aid_application_means_regular_outgoings_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      it "returns http found" do
        request
        expect(response).to have_http_status(:found)
      end

      it "redirects to the provider login page" do
        request
        expect(response).to redirect_to(new_provider_session_path)
      end
    end

    context "when the provider is authenticated" do
      before { login_as provider }

      it "returns http success" do
        request
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/means/regular_outgoings" do
    subject(:request) do
      patch(
        providers_legal_aid_application_means_regular_outgoings_path(legal_aid_application),
        params:,
      )
    end

    before { login_as provider }

    context "when none is selected" do
      let(:params) do
        {
          providers_means_regular_outgoings_form: {
            transaction_type_ids: %w[none],
          },
        }
      end

      context "and applicant has no partner" do
        it "redirects to the has dependants page" do
          request
          expect(response).to redirect_to(providers_legal_aid_application_means_has_dependants_path(legal_aid_application))
        end
      end

      context "and applicant has partner with no contrary interest" do
        let(:legal_aid_application) do
          create(:legal_aid_application,
                 :with_applicant_and_partner,
                 :with_non_passported_state_machine,
                 no_debit_transaction_types_selected: true)
        end

        it "redirects to the about financial means page" do
          request
          expect(response).to redirect_to(providers_legal_aid_application_partners_about_financial_means_path(legal_aid_application))
        end
      end

      it "updates the no debit transaction types attribute" do
        request
        expect(legal_aid_application.reload.no_debit_transaction_types_selected).to be true
      end
    end

    context "when regular transactions are selected" do
      let(:child_care) { create(:transaction_type, :child_care) }
      let(:params) do
        {
          providers_means_regular_outgoings_form: {
            transaction_type_ids: [child_care.id],
            child_care_amount: 100,
            child_care_frequency: "monthly",
          },
        }
      end

      it "does not update no debit transaction types attribute" do
        request
        expect(legal_aid_application.reload.no_debit_transaction_types_selected).to be false
      end

      it "redirects to the cash outgoings page" do
        request
        expect(response).to redirect_to(providers_legal_aid_application_means_cash_outgoing_path(legal_aid_application))
      end

      it "updates the application with the selected transaction types" do
        request
        outgoing_transaction_types = legal_aid_application.regular_transactions.debits
        expect(outgoing_transaction_types.pluck(:transaction_type_id, :amount, :frequency))
          .to contain_exactly([child_care.id, 100, "monthly"])
      end
    end

    context "when the form is invalid" do
      let(:rent_or_mortgage) { create(:transaction_type, :rent_or_mortgage) }
      let(:params) do
        {
          providers_means_regular_outgoings_form: {
            transaction_type_ids: [rent_or_mortgage.id],
            rent_or_mortgage_amount: "",
            rent_or_mortgage_frequency: "",
          },
        }
      end

      it "returns http status unprocessable entity" do
        request
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "renders errors" do
        request
        expect(page).to have_css("p", class: "govuk-error-message",
                                      text: I18n.t("activemodel.errors.models.providers/means/regular_outgoings_form.attributes.rent_or_mortgage_amount.not_a_number"))
        expect(page).to have_css("p", class: "govuk-error-message",
                                      text: I18n.t("activemodel.errors.models.providers/means/regular_outgoings_form.attributes.rent_or_mortgage_frequency.inclusion"))
      end

      it "does not update the application" do
        request
        expect(legal_aid_application.reload.regular_transactions.debits).to be_empty
      end
    end

    context "when checking answers for an application uploading bank statements and none is selected" do
      let(:legal_aid_application) do
        create(
          :legal_aid_application,
          :with_applicant,
          :with_non_passported_state_machine,
          :checking_means_income,
          no_debit_transaction_types_selected: false,
        )
      end
      let(:params) do
        {
          providers_means_regular_outgoings_form: { transaction_type_ids: ["", "none"] },
        }
      end

      it "updates the application to have no debit transaction types" do
        request
        expect(legal_aid_application.reload.no_debit_transaction_types_selected).to be true
      end

      it "redirects to the checking answers income page" do
        request
        expect(response).to redirect_to(providers_legal_aid_application_means_check_income_answers_path(legal_aid_application))
      end
    end

    context "when checking answers and regular transactions are selected" do
      let(:legal_aid_application) do
        create(
          :legal_aid_application,
          :with_applicant,
          :with_non_passported_state_machine,
          :checking_means_income,
          no_debit_transaction_types_selected: false,
        )
      end
      let(:child_care) { create(:transaction_type, :child_care) }
      let(:params) do
        {
          providers_means_regular_outgoings_form: {
            transaction_type_ids: [child_care.id],
            child_care_amount: 100,
            child_care_frequency: "monthly",
          },
        }
      end

      it "updates the application with the selected transaction types" do
        request
        identified_outgoing = legal_aid_application.regular_transactions.debits
        expect(identified_outgoing.pluck(:transaction_type_id, :amount, :frequency))
          .to contain_exactly([child_care.id, 100, "monthly"])
      end

      it "redirects to the cash outgoing page" do
        request
        expect(response).to redirect_to(providers_legal_aid_application_means_cash_outgoing_path(legal_aid_application))
      end
    end
  end
end
