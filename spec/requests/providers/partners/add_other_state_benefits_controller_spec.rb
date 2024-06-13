require "rails_helper"

RSpec.describe Providers::Partners::AddOtherStateBenefitsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_partner) }
  let(:setup) { login_as legal_aid_application.provider }
  let(:state_benefit_transaction_type) { create(:transaction_type, :benefits) }

  before do
    state_benefit_transaction_type
    setup
    make_request
  end

  describe "GET /providers/applications/:legal_aid_application_id/means/add_other_state_benefits" do
    subject(:make_request) { get providers_legal_aid_application_partners_add_other_state_benefits_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      let(:setup) { nil }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      context "and no benefits have been added" do
        it "returns the expected page with the correct heading" do
          expect(response).to have_http_status(:ok)
          expect(response.body).to include("You have added 0 benefits")
          expect(response.body).to include("Does the partner get any other benefits?")
        end
      end

      context "and a benefit has been added" do
        let(:setup) do
          create(:regular_transaction,
                 transaction_type: state_benefit_transaction_type,
                 legal_aid_application:,
                 description: "Test state benefit",
                 owner_id: legal_aid_application.partner.id,
                 owner_type: "Partner")
          login_as legal_aid_application.provider
        end

        it "returns an the expected page with the correct heading" do
          expect(response).to have_http_status(:ok)
          expect(response.body).to include("You have added 1 benefit")
          expect(response.body).to include("Does the partner get any other benefits?")
        end
      end

      context "and multiple benefit has been added" do
        let(:setup) do
          create_list(:regular_transaction, 2,
                      transaction_type: state_benefit_transaction_type,
                      legal_aid_application:,
                      description: "Test state benefit",
                      owner_id: legal_aid_application.partner.id,
                      owner_type: "Partner")
          login_as legal_aid_application.provider
        end

        it "returns an the expected page with the correct heading" do
          expect(response).to have_http_status(:ok)
          expect(response.body).to include("You have added 2 benefits")
          expect(response.body).to include("Does the partner get any other benefits?")
        end
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/means/add_other_state_benefits" do
    subject(:make_request) { patch providers_legal_aid_application_partners_add_other_state_benefits_path(legal_aid_application), params: }

    let(:params) do
      {
        binary_choice_form: {
          add_another_state_benefit:,
        },
      }
    end

    context "when the provider responds yes" do
      let(:add_another_state_benefit) { "true" }

      it "redirects to the new state benefits page" do
        expect(response).to redirect_to(new_providers_legal_aid_application_partners_state_benefit_path(legal_aid_application))
      end
    end

    context "when the provider responds no" do
      let(:add_another_state_benefit) { "false" }

      it "redirects to the partners regular income page" do
        expect(response).to redirect_to(providers_legal_aid_application_partners_regular_incomes_path(legal_aid_application))
      end
    end

    context "when the provider does not provide a response" do
      let(:add_another_state_benefit) { "" }

      it "renders the same page with an error message" do
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Select yes if they have received other benefits").twice
      end
    end

    context "when provider checking answers of citizen" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine, :checking_means_income) }

      context "and no more benefits are to be added" do
        let(:add_another_state_benefit) { "false" }

        it "redirects to the check answers income page" do
          expect(response).to redirect_to(providers_legal_aid_application_means_check_income_answers_path(legal_aid_application))
        end
      end

      context "and more benefits are to be added" do
        let(:add_another_state_benefit) { "true" }

        it "redirects to the state_benefits page" do
          expect(response).to redirect_to(new_providers_legal_aid_application_partners_state_benefit_path(legal_aid_application))
        end
      end
    end
  end
end
