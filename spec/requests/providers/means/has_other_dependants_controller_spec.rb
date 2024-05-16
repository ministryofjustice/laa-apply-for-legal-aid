require "rails_helper"

RSpec.describe Providers::Means::HasOtherDependantsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:provider) { legal_aid_application.provider }

  before { login_as provider }

  describe "GET /providers/:application_id/means/has_other_dependants" do
    subject(:request) { get providers_legal_aid_application_means_has_other_dependants_path(legal_aid_application) }

    it "returns http success" do
      request
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /providers/:application_id/means/has_other_dependants" do
    subject(:request) { patch providers_legal_aid_application_means_has_other_dependants_path(legal_aid_application), params: }

    let(:params) do
      {
        binary_choice_form: {
          has_other_dependant:,
        },
      }
    end

    context "when provider chooses yes" do
      let(:has_other_dependant) { "true" }

      it "redirects to the next page" do
        request
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when providers chooses no" do
      let(:has_other_dependant) { "false" }

      it "redirects to the next page" do
        request
        expect(response).to have_http_status(:redirect)
      end

      context "when provider is on non-passported journey without bank statement upload permissions" do
        before do
          legal_aid_application.provider.permissions.find_by(role: "application.non_passported.bank_statement_upload.*")&.destroy!
          legal_aid_application.update!(provider_received_citizen_consent: nil)
        end

        context "with transaction type debits on application" do
          before do
            legal_aid_application.transaction_types << create(:transaction_type, :debit)
          end

          it "redirects to the check answers income page" do
            request
            expect(response).to redirect_to(providers_legal_aid_application_means_check_income_answers_path(legal_aid_application))
          end
        end

        context "without transaction type debits on application" do
          before do
            legal_aid_application.transaction_types.destroy_all
          end

          it "redirects to the check answers income page" do
            request
            expect(response).to redirect_to(providers_legal_aid_application_means_check_income_answers_path(legal_aid_application))
          end
        end
      end

      context "when provider is on bank statement upload journey" do
        before do
          legal_aid_application.provider.permissions << Permission.find_or_create_by(role: "application.non_passported.bank_statement_upload.*")
          legal_aid_application.update!(provider_received_citizen_consent: false)
        end

        it "redirects to the check answers income page" do
          request
          expect(response).to redirect_to(providers_legal_aid_application_means_check_income_answers_path(legal_aid_application))
        end
      end
    end

    context "when provider chooses something else" do
      let(:has_other_dependant) { "not sure" }

      it "show errors" do
        request
        expect(response.body).to include(I18n.t("providers.has_other_dependants.show.error"))
      end
    end

    context "when provider chooses nothing" do
      let(:params) { nil }

      it "show errors" do
        request
        expect(response.body).to include(I18n.t("providers.has_other_dependants.show.error"))
      end
    end

    context "when provider checking answers of citizen and more dependants" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine, :checking_means_income) }
      let(:has_other_dependant) { "true" }

      it "redirects to the next page" do
        request
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when provider checking answers of citizen and no more dependants" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine, :checking_means_income) }
      let(:has_other_dependant) { "false" }

      it "redirects to the next page" do
        request
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
