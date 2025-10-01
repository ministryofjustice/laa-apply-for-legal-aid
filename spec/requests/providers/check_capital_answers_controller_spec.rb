require "rails_helper"

RSpec.describe Providers::CheckCapitalAnswersController do
  include ActionView::Helpers::NumberHelper

  let(:provider) { create(:provider) }
  let(:applicant) { create(:applicant) }
  let(:partner) { nil }
  let(:savings_amount) { create(:savings_amount, :with_partner_values) }
  let(:transaction_type) { create(:transaction_type) }
  let(:bank_provider) { create(:bank_provider, applicant:) }
  let(:bank_account) { create(:bank_account, bank_provider:) }
  let(:vehicles) { create_list(:vehicle, 1, :populated) }
  let(:own_vehicle) { true }
  let(:legal_aid_application) do
    create(:legal_aid_application,
           :with_negative_benefit_check_result,
           :with_non_passported_state_machine,
           :provider_assessing_means,
           :with_policy_disregards,
           :with_proceedings,
           :with_delegated_functions_on_proceedings,
           df_options: { DA001: Time.zone.today },
           vehicles:,
           own_vehicle:,
           applicant:,
           partner:,
           provider:,
           savings_amount:,
           transaction_types: [transaction_type])
  end
  let(:login) { login_as provider }

  describe "GET /providers/applications/:legal_aid_application_id/check_capital_answers" do
    subject(:request) do
      get providers_legal_aid_application_check_capital_answers_path(legal_aid_application)
    end

    before do
      login
      request
    end

    let(:vehicle) { legal_aid_application.vehicles.reload.first }

    it "returns http success" do
      expect(response).to have_http_status(:ok)
    end

    it "displays the correct vehicles details" do
      expect(response.body).to include(gds_number_to_currency(vehicle.estimated_value, unit: "£"))
      expect(response.body).to include(gds_number_to_currency(vehicle.payment_remaining, unit: "£"))
      expect(response.body).to include(yes_no(vehicle.more_than_three_years_old?))
      expect(response.body).to include(I18n.t("shared.check_answers.vehicles.providers.heading"))
      expect(response.body).to include(I18n.t("govuk_component.summary_list_component.card_component.vehicles.providers.own", individual: "your client"))
      expect(response.body).to include(I18n.t("govuk_component.summary_list_component.card_component.vehicles.providers.estimated_value"))
      expect(response.body).to include(I18n.t("govuk_component.summary_list_component.card_component.vehicles.providers.payment_remaining"))
      expect(response.body).to include(I18n.t("govuk_component.summary_list_component.card_component.vehicles.providers.more_than_three_years_old"))
      expect(response.body).to include(I18n.t("govuk_component.summary_list_component.card_component.vehicles.providers.used_regularly"))
    end

    context "when not logged in" do
      let(:login) { nil }

      it_behaves_like "a provider not authenticated"
    end

    context "when applicant does not have vehicle" do
      let(:vehicles) { [] }
      let(:own_vehicle) { false }

      it "displays first vehicle question" do
        expect(response.body).to include(I18n.t("govuk_component.summary_list_component.card_component.vehicles.providers.own", individual: "your client"))
      end

      it "does not display other vehicle questions" do
        expect(response.body).not_to include("What is the estimated value of the vehicle?")
        expect(response.body).not_to include("Are there any payments left on the vehicle?")
        expect(response.body).not_to include("Vehicle was bought over 3 years ago?")
        expect(response.body).not_to include("Vehicle is in regular use?")
      end
    end

    context "when applicant has partner" do
      let(:applicant) { create(:applicant, has_partner: true, partner_has_contrary_interest: false) }
      let(:partner) { create(:partner) }

      context "and they own a vehicle" do
        let(:own_vehicle) { true }
        let(:vehicles) { create_list(:vehicle, 1, :owned_by_partner) }

        it "shows 'The partner' as the owner" do
          expect(response.body).to have_css("#app-check-your-answers__vehicles_owner", text: "The partner")
        end
      end

      context "and they have offline bank_accounts" do
        it "shows the partner bank values" do
          expect(page)
            .to have_css("#app-check-your-answers__partner_current_accounts", text: "Current account")
            .and have_css("#app-check-your-answers__partner_savings_accounts", text: "Savings account")
        end
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/check_capital_answers" do
    subject(:request) do
      get providers_legal_aid_application_check_capital_answers_path(legal_aid_application)
      patch providers_legal_aid_application_check_capital_answers_path(legal_aid_application), params:
    end

    let(:params) { {} }

    context "when unauthenticated" do
      before { request }

      it_behaves_like "a provider not authenticated"
    end

    context "when logged in as an authenticated provider" do
      before do
        login
        allow(CFECivil::SubmissionBuilder).to receive(:call).with(legal_aid_application).and_return(cfe_result)
      end

      context "with a successful Check Financial Eligibility Service call" do
        let(:cfe_result) { true }

        it "transitions to provider_entering_merits state" do
          request
          expect(legal_aid_application.reload.provider_entering_merits?).to be true
        end

        context "when provider has bank_statement_upload permissions and has not received open banking consent" do
          before do
            legal_aid_application.provider.permissions << Permission.find_or_create_by(role: "application.non_passported.bank_statement_upload.*")
            legal_aid_application.update!(provider_received_citizen_consent: false)
          end

          it "redirects to the capital income assessment page" do
            request
            expect(response).to redirect_to(providers_legal_aid_application_capital_income_assessment_result_path(legal_aid_application))
          end

          it "calls CFE::SubmissionRouter" do
            request
            expect(CFECivil::SubmissionBuilder).to have_received(:call).with(legal_aid_application)
          end
        end

        context "when provider is not uploading bank statements" do
          before do
            legal_aid_application.update!(provider_received_citizen_consent: true)
          end

          it "redirects to the next page" do
            request
            expect(response).to have_http_status(:redirect)
          end

          it "calls CFE::SubmissionManager" do
            request
            expect(CFECivil::SubmissionBuilder).to have_received(:call).with(legal_aid_application)
          end
        end

        context "when form submitted using Save as draft button" do
          let(:params) { { draft_button: "irrelevant" } }

          it "redirects provider to provider's applications page" do
            request
            expect(response).to redirect_to(in_progress_providers_legal_aid_applications_path)
          end

          it "sets the application as draft" do
            request
            expect(legal_aid_application.reload).to be_draft
          end

          it "does not calls CFE::SubmissionManager" do
            request
            expect(CFECivil::SubmissionBuilder).not_to have_received(:call)
          end
        end
      end

      context "when call to Check Financial Eligibility Service is unsuccessful" do
        let(:cfe_result) { false }

        it "redirects to the problem page" do
          request
          expect(response).to redirect_to(problem_index_path)
        end
      end
    end
  end

  def yes_no(value)
    value ? "Yes" : "No"
  end
end
