require "rails_helper"

RSpec.describe "EmergencyLevelOfServiceController", :vcr do
  let(:application) do
    create(:legal_aid_application,
           :with_proceedings,
           :with_delegated_functions_on_proceedings,
           explicit_proceedings: %i[da001],
           df_options: { DA001: [10.days.ago, 10.days.ago] },
           substantive_application_deadline_on: 10.days.from_now)
  end
  let(:application_id) { application.id }
  let(:proceeding) { application.proceedings.first }
  let(:proceeding_id) { proceeding.id }
  let(:provider) { application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/emergency_level_of_service/:proceeding_id" do
    subject(:get_elos) { get "/providers/applications/#{application_id}/emergency_level_of_service/#{proceeding_id}" }

    context "when the provider is not authenticated" do
      before { get_elos }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_elos
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays the proceeding header" do
        expect(response.body).to include("Proceeding 1")
        expect(response.body).to include("Inherent jurisdiction high court injunction")
      end

      context "when the proceeding has only one possible level of service" do
        it "displays a message that the level of service cannot be changed" do
          expect(response.body).to include("You cannot change the default level of service for the emergency application for this proceeding")
        end
      end

      context "when the proceeding has more than one possible level of service" do
        let(:application) do
          create(:legal_aid_application,
                 :with_proceedings,
                 :with_delegated_functions_on_proceedings,
                 explicit_proceedings: %i[se013],
                 df_options: { SE013: [10.days.ago, 10.days.ago] },
                 substantive_application_deadline_on: 10.days.from_now)
        end

        it "asks the user to select a level of service" do
          expect(response.body).to include("For the emergency application, select the level of service")
        end
      end
    end
  end

  describe "POST /providers/applications/:legal_aid_application_id/emergency_level_of_service/:proceeding_id" do
    subject(:post_elos) { patch "/providers/applications/#{application_id}/emergency_level_of_service/#{proceeding_id}", params: }

    let(:params) do
      {
        proceeding: {
          emergency_level_of_service:,
        },
      }
    end
    let(:emergency_level_of_service) { 3 }

    context "when the provider is not authenticated" do
      before { post_elos }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "when the Continue button is pressed" do
        let(:submit_button) { { continue_button: "Continue" } }

        it "redirects to the next page" do
          post_elos
          expect(response).to have_http_status(:redirect)
        end

        context "when the parameters are invalid" do
          before do
            proceeding.update!(emergency_level_of_service: nil, emergency_level_of_service_name: nil, emergency_level_of_service_stage: nil)
            post_elos
          end

          let(:emergency_level_of_service) { nil }

          it "returns http_success" do
            expect(response).to have_http_status(:ok)
          end

          it "the response includes the error message" do
            expect(response.body).to include("Select a level of service")
          end
        end

        context "when the provider changes the default LoS to Full representation" do
          before do
            allow(LegalFramework::ProceedingTypes::Defaults).to receive(:call).and_return(
              {
                "success" => true,
                "requested_params" => { "proceeding_type_ccms_code" => "DA001", "delegated_functions_used" => true, "client_involvement_type" => "A" },
                "default_level_of_service" => { "level" => 1, "name" => "FHH Children", "stage" => 8 },
                "default_scope" =>
                  {
                    "code" => "CV117",
                    "meaning" => "Interim order inc. return date",
                    "description" => "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.",
                    "additional_params" => [],
                  },
              }.to_json,
            )
          end

          it "redirects to final_hearing page" do
            post_elos
            expect(response.body).to redirect_to(providers_legal_aid_application_final_hearings_path(application_id, proceeding_id, :emergency))
          end
        end
      end
    end
  end
end
