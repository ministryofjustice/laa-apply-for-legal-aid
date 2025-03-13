require "rails_helper"

RSpec.describe Providers::Means::AddOtherVehiclesController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:login) { login_as legal_aid_application.provider }
  let(:vehicle) { legal_aid_application.vehicles.first }
  let(:setup) { nil }

  before do
    setup
    login
    make_request
  end

  describe "GET /providers/applications/:legal_aid_application_id/means/add_other_vehicles" do
    subject(:make_request) { get providers_legal_aid_application_means_add_other_vehicles_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      let(:login) { nil }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      context "and no vehicles have been added" do
        it "returns the expected page with the correct heading" do
          expect(response).to have_http_status(:ok)
          expect(response.body).to include("You have added 0 vehicles")
        end
      end

      context "and a vehicle has been added" do
        let(:setup) { create(:vehicle, estimated_value: 1_234, used_regularly: true, more_than_three_years_old: true, legal_aid_application:) }

        it "returns the expected page with the correct heading" do
          expect(response).to have_http_status(:ok)
          expect(response.body).to include("You have added 1 vehicle")
          expect(response.body).to have_css("dt", text: "Vehicle worth £1,234")
        end
      end

      context "and an incomplete vehicle has been added" do
        let(:setup) { create_list(:vehicle, 1, legal_aid_application:) }

        it "returns the expected page with the correct heading" do
          expect(response).to have_http_status(:ok)
          expect(response.body).to include("You have added 1 vehicle")
          expect(response.body).to have_css("dt", text: "Vehicle record")
          expect(response.body).to have_css("dd", text: "Incomplete")
        end
      end

      context "and multiple vehicles has been added" do
        let(:setup) { create_list(:vehicle, 2, legal_aid_application:) }

        it "returns an the expected page with the correct heading" do
          expect(response).to have_http_status(:ok)
          expect(response.body).to include("You have added 2 vehicles")
        end
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/means/add_vehicles" do
    subject(:make_request) { patch providers_legal_aid_application_means_add_other_vehicles_path(legal_aid_application), params: }

    let(:params) do
      {
        binary_choice_form: {
          add_another_vehicle:,
        },
      }
    end

    context "when the provider responds yes" do
      let(:add_another_vehicle) { "true" }

      it "redirects to next page" do
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when the provider responds no" do
      let(:add_another_vehicle) { "false" }

      context "and the application is non-passported" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_vehicle, :non_passported) }

        it "redirects to next step" do
          expect(response).to have_http_status(:redirect)
        end
      end

      context "and the application is passported" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_vehicle, :passported) }

        it "redirects to next step" do
          expect(response).to have_http_status(:redirect)
        end
      end
    end

    context "when the provider does not provide a response" do
      let(:add_another_vehicle) { "" }

      it "renders the same page with an error message" do
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Select yes if they have other vehicles").twice
      end
    end

    context "when provider checking answers" do
      describe "for a non-passported application" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine, :checking_non_passported_means) }

        context "and no more vehicles are to be added" do
          let(:add_another_vehicle) { "false" }

          it "redirects to the check capital answers page" do
            expect(response).to redirect_to(providers_legal_aid_application_check_capital_answers_path(legal_aid_application))
          end
        end

        context "and more vehicles are to be added" do
          let(:add_another_vehicle) { "true" }

          it "redirects to the next cya page" do
            expect(response).to have_http_status(:redirect)
          end
        end
      end

      describe "for a passported application" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_passported_state_machine, :checking_passported_answers) }

        context "and no more vehicles are to be added" do
          let(:add_another_vehicle) { "false" }

          it "redirects to the next cya page" do
            expect(response).to have_http_status(:redirect)
          end
        end

        context "and more vehicles are to be added" do
          let(:add_another_vehicle) { "true" }

          it "redirects to the next cya page" do
            expect(response).to have_http_status(:redirect)
          end
        end
      end
    end
  end
end
