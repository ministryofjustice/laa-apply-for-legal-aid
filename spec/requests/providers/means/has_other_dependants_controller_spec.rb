require "rails_helper"

RSpec.describe Providers::Means::HasOtherDependantsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
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

      it "redirects to the page to add another dependant" do
        request
        expect(response).to redirect_to(new_providers_legal_aid_application_means_dependant_path(legal_aid_application))
      end
    end

    context "when providers chooses no" do
      let(:has_other_dependant) { "false" }

      it "redirects to the outgoings summary page" do
        request
        expect(response).to redirect_to(providers_legal_aid_application_no_outgoings_summary_path(legal_aid_application))
      end

      context "when provider does not have bank_statement_upload permissions" do
        before do
          legal_aid_application.provider.permissions.find_by(role: "application.non_passported.bank_statement_upload.*")&.destroy
        end

        context "with transaction type debits on application" do
          before do
            legal_aid_application.transaction_types << create(:transaction_type, :debit)
          end

          it "redirects to the outgoings summary index page" do
            request
            expect(response).to redirect_to(providers_legal_aid_application_outgoings_summary_index_path(legal_aid_application))
          end
        end

        context "without transaction type debits on application" do
          before do
            legal_aid_application.transaction_types.destroy_all
          end

          it "redirects to the no outgoings summary index page" do
            request
            expect(response).to redirect_to(providers_legal_aid_application_no_outgoings_summary_path(legal_aid_application))
          end
        end
      end

      context "when provider does have bank_statement_upload permissions" do
        before do
          legal_aid_application.provider.permissions << Permission.find_or_create_by(role: "application.non_passported.bank_statement_upload.*")
        end

        it "redirects to the means student finance page" do
          request
          expect(response).to redirect_to(providers_legal_aid_application_means_own_home_path(legal_aid_application))
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
      let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :with_non_passported_state_machine, :checking_non_passported_means }
      let(:has_other_dependant) { "true" }

      it "redirects to the page to add another dependant" do
        request
        expect(response).to redirect_to(new_providers_legal_aid_application_means_dependant_path(legal_aid_application))
      end
    end

    context "when provider checking answers of citizen and no more dependants" do
      let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :with_non_passported_state_machine, :checking_non_passported_means }
      let(:has_other_dependant) { "false" }

      it "redirects to the means summary page" do
        request
        expect(response).to redirect_to(providers_legal_aid_application_means_summary_path(legal_aid_application))
      end
    end
  end
end
