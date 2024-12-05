require "rails_helper"

RSpec.describe "EmergencyDefaultsController", :vcr do
  let(:application) do
    create(
      :legal_aid_application,
      :with_proceedings,
      :with_delegated_functions_on_proceedings,
      explicit_proceedings: %i[da001],
      df_options: { DA001: [10.days.ago, 10.days.ago] },
      substantive_application_deadline_on: 10.days.from_now,
    ).tap do |app|
      app.proceedings.first.update!(
        emergency_level_of_service: nil,
        emergency_level_of_service_name: nil,
        emergency_level_of_service_stage: nil,
        substantive_level_of_service: nil,
        substantive_level_of_service_name: nil,
        substantive_level_of_service_stage: nil,
      )
    end
  end

  let(:proceeding) { application.proceedings.first }
  let(:provider) { application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/emergency_defaults/:proceeding_id" do
    subject(:get_sd) { get "/providers/applications/#{application.id}/emergency_defaults/#{proceeding.id}" }

    context "when the provider is not authenticated" do
      before { get_sd }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_sd
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays the proceeding header" do
        expect(response.body).to include("Proceeding 1")
        expect(response.body).to include("Inherent jurisdiction high court injunction")
        expect(response.body).to include("Do you want to use the default level of service and scope for the emergency application?")
      end
    end
  end

  describe "POST /providers/applications/:legal_aid_application_id/emergency_defaults/:proceeding_id" do
    subject(:post_sd) { patch "/providers/applications/#{application.id}/emergency_defaults/#{proceeding.id}", params: }

    before { allow(DelegatedFunctionsDateService).to receive(:call).and_return(true) }

    let(:params) do
      {
        proceeding: {
          accepted_emergency_defaults: false,
        },
      }
    end

    context "when the provider is not authenticated" do
      before { post_sd }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "when the Continue button is pressed" do
        let(:submit_button) { { continue_button: "Continue" } }

        context "when the provider accepts the defaults" do
          let(:params) do
            {
              proceeding: {
                accepted_emergency_defaults: true,
              },
            }
          end

          it "redirects to next page" do
            post_sd
            expect(response.body).to redirect_to(providers_legal_aid_application_substantive_default_path(application.id, proceeding.id))
          end

          it "sets the default emergency levels of service" do
            expect { post_sd }.to change { proceeding.reload.attributes.symbolize_keys }
              .from(
                hash_including(
                  {
                    emergency_level_of_service: nil,
                    emergency_level_of_service_name: nil,
                    emergency_level_of_service_stage: nil,
                  },
                ),
              ).to(
                hash_including(
                  {
                    emergency_level_of_service: 3,
                    emergency_level_of_service_name: "Full Representation",
                    emergency_level_of_service_stage: 8,
                  },
                ),
              )
          end
        end

        context "when the provider does not accept the defaults" do
          let(:params) do
            {
              proceeding: {
                accepted_emergency_defaults: false,
              },
            }
          end

          it "redirects to next page" do
            post_sd
            expect(response.body).to redirect_to(providers_legal_aid_application_emergency_level_of_service_path(application.id, proceeding.id))
          end

          it "clears the emergency levels of service" do
            expect { post_sd }.to change { proceeding.reload.attributes.symbolize_keys }
              .from(
                hash_including(
                  {
                    emergency_level_of_service: nil,
                    emergency_level_of_service_name: nil,
                    emergency_level_of_service_stage: nil,
                  },
                ),
              ).to(
                hash_including(
                  {
                    emergency_level_of_service: nil,
                    emergency_level_of_service_name: nil,
                    emergency_level_of_service_stage: nil,
                  },
                ),
              )
          end
        end

        context "when checking answers" do
          let(:application) do
            create(:legal_aid_application,
                   :with_proceedings,
                   :checking_applicant_details,
                   :with_delegated_functions_on_proceedings,
                   explicit_proceedings: %i[da001],
                   df_options: { DA001: [10.days.ago, 10.days.ago] },
                   substantive_application_deadline_on: 10.days.from_now)
          end

          before { application.reload }

          context "when the date is within the last month" do
            it "continues through the sub flow" do
              post_sd
              expect(response).to redirect_to(providers_legal_aid_application_emergency_level_of_service_path(application.id))
            end
          end
        end
      end
    end
  end
end
