require "rails_helper"

RSpec.describe Providers::MeansSummariesController do
  include ActionView::Helpers::NumberHelper
  let(:provider) { create(:provider) }
  let(:applicant) { create(:applicant) }
  let(:transaction_type) { create(:transaction_type) }
  let(:bank_provider) { create(:bank_provider, applicant:) }
  let(:bank_account) { create(:bank_account, bank_provider:) }
  let(:vehicle) { create(:vehicle, :populated) }
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
           vehicle:,
           own_vehicle:,
           applicant:,
           provider:,
           transaction_types: [transaction_type])
  end
  let(:login) { login_as provider }

  describe "GET /providers/applications/:legal_aid_application_id/means_summary" do
    subject(:request) do
      get providers_legal_aid_application_means_summary_path(legal_aid_application)
    end

    let!(:bank_transactions) { create_list(:bank_transaction, 3, transaction_type:, bank_account:) }

    before do
      login
      request
    end

    it "returns http success" do
      expect(response).to have_http_status(:ok)
    end

    it "displays the bank transaction data" do
      total_amount = bank_transactions.sum(&:amount)
      expect(total_amount).not_to be_zero
      expect(response.body).to include(ActiveSupport::NumberHelper.gds_number_to_currency(total_amount))
    end

    it "displays the correct vehicles details" do
      expect(response.body).to include(gds_number_to_currency(vehicle.estimated_value, unit: "£"))
      expect(response.body).to include(gds_number_to_currency(vehicle.payment_remaining, unit: "£"))
      expect(response.body).to include(yes_no(vehicle.more_than_three_years_old?))
      expect(response.body).to include(I18n.t("shared.check_answers.vehicles.providers.heading"))
      expect(response.body).to include(I18n.t("shared.check_answers.vehicles.providers.own"))
      expect(response.body).to include(I18n.t("shared.check_answers.vehicles.providers.estimated_value"))
      expect(response.body).to include(I18n.t("shared.check_answers.vehicles.providers.payment_remaining"))
      expect(response.body).to include(I18n.t("shared.check_answers.vehicles.providers.more_than_three_years_old"))
      expect(response.body).to include(I18n.t("shared.check_answers.vehicles.providers.used_regularly"))
    end

    context "when not logged in" do
      let(:login) { nil }

      it_behaves_like "a provider not authenticated"
    end

    context "applicant does not have vehicle" do
      let(:vehicle) { nil }
      let(:own_vehicle) { false }

      it "displays first vehicle question" do
        expect(response.body).to include(I18n.t("shared.check_answers.vehicles.providers.own"))
      end

      it "does not display other vehicle questions" do
        expect(response.body).not_to include(I18n.t("shared.check_answers_vehicles.providers.estimated_value"))
        expect(response.body).not_to include(I18n.t("shared.check_answers_vehicles.providers.payment_remaining"))
        expect(response.body).not_to include(I18n.t("shared.check_answers_vehicles.providers.purchased_on"))
        expect(response.body).not_to include(I18n.t("shared.check_answers_vehicles.providers.used_regularly"))
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/means_summary" do
    subject(:request) do
      get providers_legal_aid_application_means_summary_path(legal_aid_application)
      patch providers_legal_aid_application_means_summary_path(legal_aid_application), params:
    end

    let(:params) { {} }

    context "when unauthenticated" do
      before { request }

      it_behaves_like "a provider not authenticated"
    end

    context "when logged in as an authenticated provider" do
      before do
        login
        allow(CFE::SubmissionManager).to receive(:call).with(legal_aid_application.id).and_return(cfe_result)
      end

      context "with a successful Check Financial Eligibility Service call" do
        let(:cfe_result) { true }

        it "transitions to provider_entering_merits state" do
          request
          expect(legal_aid_application.reload.provider_entering_merits?).to be true
        end

        context "when provider has bank_statement_upload permissions and enhanced_bank_upload is disabled" do
          before do
            allow(Setting).to receive(:enhanced_bank_upload?).and_return(false)
            legal_aid_application.provider.permissions << Permission.find_or_create_by(role: "application.non_passported.bank_statement_upload.*")
            legal_aid_application.update!(provider_received_citizen_consent: false)
          end

          it "redirects to the no eligibility assessment page" do
            request
            expect(response).to redirect_to(providers_legal_aid_application_no_eligibility_assessment_path(legal_aid_application))
          end

          it "does not calls CFE::SubmissionManager" do
            request
            expect(CFE::SubmissionManager).not_to have_received(:call)
          end
        end

        context "when provider has bank_statement_upload permissions and enhanced_bank_upload is enabled" do
          before do
            allow(Setting).to receive(:enhanced_bank_upload?).and_return(true)
            legal_aid_application.provider.permissions << Permission.find_or_create_by(role: "application.non_passported.bank_statement_upload.*")
            legal_aid_application.update!(provider_received_citizen_consent: false)
          end

          it "redirects to the capital income assessment page" do
            request
            expect(response).to redirect_to(providers_legal_aid_application_capital_income_assessment_result_path(legal_aid_application))
          end

          it "calls CFE::SubmissionManager" do
            request
            expect(CFE::SubmissionManager).to have_received(:call).with(legal_aid_application.id)
          end
        end

        context "when provider is not uploading bank statements" do
          before do
            legal_aid_application.update!(provider_received_citizen_consent: true)
          end

          it "redirects to the capital income assessment page" do
            request
            expect(response).to redirect_to(providers_legal_aid_application_capital_income_assessment_result_path(legal_aid_application))
          end

          it "calls CFE::SubmissionManager" do
            request
            expect(CFE::SubmissionManager).to have_received(:call).with(legal_aid_application.id)
          end
        end

        context "when form submitted using Save as draft button" do
          let(:params) { { draft_button: "irrelevant" } }

          it "redirects provider to provider's applications page" do
            request
            expect(response).to redirect_to(providers_legal_aid_applications_path)
          end

          it "sets the application as draft" do
            request
            expect(legal_aid_application.reload).to be_draft
          end

          it "does not calls CFE::SubmissionManager" do
            request
            expect(CFE::SubmissionManager).not_to have_received(:call)
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

    context "when in as authenticated provider with bank statement upload permissions" do
      before do
        login
        legal_aid_application.provider.permissions << Permission.find_or_create_by(role: "application.non_passported.bank_statement_upload.*")
      end

      it "expect cfe_result to be nil" do
        request
        expect(legal_aid_application.cfe_result).to be_nil
      end
    end
  end

  def yes_no(value)
    value ? "Yes" : "No"
  end
end
