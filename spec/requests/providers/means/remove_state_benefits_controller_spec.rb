require "rails_helper"

RSpec.describe Providers::Means::RemoveStateBenefitsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:login) { login_as legal_aid_application.provider }
  let(:state_benefit_transaction_type) { create(:transaction_type, :benefits) }
  let(:chosen_transaction) do
    create(:regular_transaction,
           transaction_type: state_benefit_transaction_type,
           legal_aid_application:,
           description: "Test removal of state benefit",
           owner_id: legal_aid_application.applicant.id,
           owner_type: "Applicant")
  end
  let(:extra_transaction_count) { 0 }

  before do
    create_list(:regular_transaction, extra_transaction_count,
                transaction_type: state_benefit_transaction_type,
                legal_aid_application:,
                description: "Test state benefit #{SecureRandom.uuid}",
                owner_id: legal_aid_application.applicant.id,
                owner_type: "Applicant")
    login
    make_request
  end

  describe "GET /providers/:application_id/means/remove_state_benefits/:regular_transaction_id" do
    subject(:make_request) { get providers_legal_aid_application_means_remove_state_benefit_path(legal_aid_application, chosen_transaction) }

    it "renders the expected page" do
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Are you sure you want to remove Test removal of state benefit?")
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }

      it_behaves_like "a provider not authenticated"
    end
  end

  describe "PATCH /providers/:application_id/means/remove_state_benefits/:regular_transaction_id" do
    subject(:make_request) { patch providers_legal_aid_application_means_remove_state_benefit_path(legal_aid_application, chosen_transaction), params: }

    let(:params) do
      {
        binary_choice_form: {
          remove_state_benefit:,
        },
      }
    end

    context "when there are further state_benefits" do
      let(:extra_transaction_count) { 2 }

      context "and the provider confirms deletion" do
        let(:remove_state_benefit) { "true" }

        it "redirects along the flow" do
          expect(response).to have_http_status(:redirect)
        end
      end

      context "and the provider rejects deletion" do
        let(:remove_state_benefit) { "false" }

        it "redirects along the flow" do
          expect(response).to have_http_status(:redirect)
        end
      end

      context "and the provider does not provide a response" do
        let(:remove_state_benefit) { "" }

        it "redirects to the add other state benefits page" do
          expect(response).to have_http_status(:ok)
          expect(response.body).to include("Select yes if you wish to remove this benefit").twice
        end
      end
    end

    context "when there are no further state_benefits" do
      context "and the provider confirms deletion" do
        let(:remove_state_benefit) { "true" }

        it "redirects along the flow" do
          expect(response).to have_http_status(:redirect)
        end
      end

      context "and the provider rejects deletion" do
        let(:remove_state_benefit) { "false" }

        it "redirects along the flow" do
          expect(response).to have_http_status(:redirect)
        end
      end

      context "and the provider does not provide a response" do
        let(:remove_state_benefit) { "" }

        it "redirects to the add other state benefits page" do
          expect(response).to have_http_status(:ok)
          expect(response.body).to include("Select yes if you wish to remove this benefit").twice
        end
      end
    end
  end
end
