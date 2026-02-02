require "rails_helper"

RSpec.describe Providers::Means::CapitalDisregards::AddDetailsController do
  let(:application) { create(:legal_aid_application, :with_applicant) }
  let(:provider) { application.provider }
  let(:disregard) { create(:capital_disregard, legal_aid_application: application) }

  describe "GET providers/applications/:legal_aid_application_id/means/capital_disregards/add_details/:id" do
    subject(:get_request) { get providers_legal_aid_application_means_capital_disregards_add_detail_path(application, disregard) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_request
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays the show page" do
        expect(response.body).to include("Add details for")
      end
    end
  end

  describe "PATCH providers/applications/:legal_aid_application_id/means/capital_disregards/add_details/:id" do
    let(:params) do
      {
        capital_disregard: {
          amount:,
          account_name:,
          "date_received(3i)": date_received_3i,
          "date_received(2i)": date_received_2i,
          "date_received(1i)": date_received_1i,
        },
        continue_button: "Save and continue",
      }
    end
    let(:amount) { nil }
    let(:account_name) { nil }
    let(:date_received_3i) { "" }
    let(:date_received_2i) { "" }
    let(:date_received_1i) { "" }

    context "when the provider is authenticated" do
      before do
        login_as provider
        patch(providers_legal_aid_application_means_capital_disregards_add_detail_path(application, disregard), params:)
      end

      context "when submitted with no parameters populated" do
        it "renders successfully" do
          expect(response).to have_http_status(:ok)
        end

        it "displays error" do
          expect(response.body).to include("govuk-error-summary")
        end
      end

      context "with valid params" do
        let(:amount) { 1234 }
        let(:valid_date) { Date.yesterday }
        let(:account_name) { "Account name" }
        let(:date_received_3i) { valid_date.day }
        let(:date_received_2i) { valid_date.month }
        let(:date_received_1i) { valid_date.year }

        it "redirects to the next page" do
          expect(response).to have_http_status(:redirect)
        end

        it "updates the record" do
          expect(application.capital_disregards.first.amount).to eq 1234
          expect(application.capital_disregards.first.account_name).to eq "Account name"
          expect(application.capital_disregards.first.date_received).to eq valid_date
          expect(application.capital_disregards.first.payment_reason).to be_nil
        end
      end
    end
  end
end
