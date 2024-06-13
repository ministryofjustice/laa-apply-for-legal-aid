require "rails_helper"

RSpec.describe Providers::Means::StateBenefitsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:login) { login_as legal_aid_application.provider }
  let(:state_benefit_transaction_type) { create(:transaction_type, :benefits) }

  before do
    state_benefit_transaction_type
    login
    make_request
  end

  describe "GET /providers/applications/:legal_aid_application_id/means/add_state_benefits/new" do
    subject(:make_request) { get new_providers_legal_aid_application_means_state_benefit_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      let(:login) { nil }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      it "returns an the expected page with the correct heading" do
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Add benefit details")
      end
    end
  end

  describe "GET /providers/applications/:legal_aid_application_id/means/add_state_benefits/:regular_transaction_id" do
    subject(:make_request) { get providers_legal_aid_application_means_state_benefit_path(legal_aid_application, state_benefit_transaction) }

    let(:state_benefit_transaction) do
      create(:regular_transaction,
             transaction_type: state_benefit_transaction_type,
             legal_aid_application:, description: "Test state benefit")
    end

    context "when the user has clicked the change link for an existing benefit payment" do
      it "returns the expected page with the correct heading" do
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Amend benefit details")
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/means/add_state_benefits/:regular_transaction_id" do
    subject(:make_request) { patch(providers_legal_aid_application_means_state_benefit_path(legal_aid_application, state_benefit_transaction), params:) }

    let(:state_benefit_transaction) do
      create(:regular_transaction,
             transaction_type: state_benefit_transaction_type,
             legal_aid_application:,
             description: "Test state benefit",
             amount: "1000.00",
             frequency: "four_weekly",
             owner_type: "Applicant",
             owner_id: legal_aid_application.applicant.id)
    end
    let(:params) do
      {
        regular_transaction: {
          transaction_type_id: state_benefit_transaction_type.id,
          description:,
          amount:,
          frequency:,
        },
      }
    end
    let(:description) { "Child benefit" }
    let(:amount) { "21.80" }
    let(:frequency) { "weekly" }

    context "when the parameters are all valid" do
      it "redirects to the next page" do
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when parameters are invalid" do
      let(:description) { "" }
      let(:amount) { "" }
      let(:frequency) { "" }

      it "returns an the same page with the expected errors showing" do
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Enter the name of the benefit")
        expect(response.body).to include("Enter the amount of benefit received")
        expect(response.body).to include("Select how often your client gets the benefit")
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/means/add_state_benefits/new" do
    subject(:make_request) { patch(new_providers_legal_aid_application_means_state_benefit_path(legal_aid_application), params:) }

    let(:params) do
      {
        regular_transaction: {
          transaction_type_id: state_benefit_transaction_type.id,
          description:,
          amount:,
          frequency:,
        },
      }
    end
    let(:description) { "Child benefit" }
    let(:amount) { "21.80" }
    let(:frequency) { "weekly" }

    context "when the parameters are all valid" do
      it "redirects to the next page" do
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when parameters are invalid" do
      let(:description) { "" }
      let(:amount) { "" }
      let(:frequency) { "" }

      it "returns an the same page with the expected errors showing" do
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Enter the name of the benefit")
        expect(response.body).to include("Enter the amount of benefit received")
        expect(response.body).to include("Select how often your client gets the benefit")
      end
    end
  end
end
