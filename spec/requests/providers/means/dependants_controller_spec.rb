require "rails_helper"

RSpec.describe Providers::Means::DependantsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:login) { login_as legal_aid_application.provider }

  before do
    login
  end

  describe "GET /providers/:application_id/means/dependants/new" do
    before { get new_providers_legal_aid_application_means_dependant_path(legal_aid_application) }

    it "returns http success" do
      expect(response).to have_http_status(:ok)
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }

      it_behaves_like "a provider not authenticated"
    end
  end

  describe "GET /providers/applications/:legal_aid_application_id/means/dependants/:dependant_id" do
    before { get(providers_legal_aid_application_means_dependant_path(legal_aid_application, dependant)) }

    let(:dependant) { create(:dependant, legal_aid_application:) }

    it "renders successfully" do
      expect(response).to have_http_status(:ok)
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }

      it_behaves_like "a provider not authenticated"
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/means/dependants/dependant_id" do
    subject(:patch_request) do
      patch(
        providers_legal_aid_application_means_dependant_path(legal_aid_application, dependant),
        params:,
      )
    end

    before { patch_request }

    let(:dependant) { create(:dependant, legal_aid_application:) }
    let(:params) do
      {
        dependant: {
          name: "bob",
          dob_day: 1,
          dob_month: 1,
          dob_year: 1990,
          relationship: "child_relative",
          monthly_income: "",
          has_income: "false",
          in_full_time_education: "false",
          has_assets_more_than_threshold: "false",
          assets_value: "",
        },
      }
    end

    context "when the parameters are valid" do
      it "redirects to the next page" do
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when provider is checking answers of citizen" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine, :checking_means_income) }

      it "redirects to the next page" do
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when there are extra whitespaces in dependant name" do
      let(:params) do
        {
          dependant: {
            name: "   bob  john  ",
            dob_day: 1,
            dob_month: 1,
            dob_year: 1990,
            relationship: "child_relative",
            monthly_income: "",
            has_income: "false",
            in_full_time_education: "false",
            has_assets_more_than_threshold: "false",
            assets_value: "",
          },
        }
      end

      it "strips and trims whitespaces from dependant name" do
        patch_request
        dependant = legal_aid_application.reload.dependants.first
        expect(dependant.name).to eq "bob john"
      end
    end

    context "when the parameters are invalid" do
      let(:params) do
        {
          dependant: {
            name: "bob",
            dob_day: 1,
            dob_month: 1,
            dob_year: 1990,
            relationship: "",
            monthly_income: "",
            has_income: "true",
            in_full_time_education: "",
            has_assets_more_than_threshold: "true",
            assets_value: "",
          },
        }
      end

      it "displays error" do
        expect(response.body).to include("govuk-error-summary")
      end

      it "renders successfully" do
        expect(response).to have_http_status(:ok)
      end
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }

      it_behaves_like "a provider not authenticated"
    end

    context "when form submitted with Save as draft button" do
      let(:params) do
        {
          dependant: {
            name: "",
            dob_day: nil,
            dob_month: nil,
            dob_year: nil,
            relationship: "",
            monthly_income: "",
            has_income: "",
            in_full_time_education: "",
            has_assets_more_than_threshold: "",
            assets_value: "",
          },
          draft_button: "Save and come back later",
        }
      end

      it "redirects to the list of applications" do
        expect(response).to redirect_to in_progress_providers_legal_aid_applications_path
      end
    end
  end
end
