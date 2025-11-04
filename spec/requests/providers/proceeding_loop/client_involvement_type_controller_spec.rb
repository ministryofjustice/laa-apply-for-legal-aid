require "rails_helper"

def client_involvement_types_da001_response
  {
    success: true,
    client_involvement_type: [
      {
        ccms_code: "A",
        description: "Applicant/claimant/petitioner",
      },
      {
        ccms_code: "D",
        description: "Defendant/respondent",
      },
      {
        ccms_code: "W",
        description: "Subject of proceedings (child)",
      },
      {
        ccms_code: "I",
        description: "Intervenor",
      },
      {
        ccms_code: "Z",
        description: "Joined party",
      },
    ],
  }.to_json
end

RSpec.describe "ClientInvolvementTypeController" do
  let(:application) { create(:legal_aid_application, :with_proceedings) }
  let(:proceeding) { application.proceedings.first }
  let(:provider) { application.provider }

  before do
    stub_request(:get, %r{#{Rails.configuration.x.legal_framework_api_host}/client_involvement_types/DA001})
      .to_return(
        status: 200,
        body: client_involvement_types_da001_response,
        headers: { "Content-Type" => "application/json; charset=utf-8" },
      )
  end

  describe "GET /providers/applications/:legal_aid_application_id/client_involvement_type/:proceeding_id" do
    subject(:get_cit) { get "/providers/applications/#{application.id}/client_involvement_type/#{proceeding.id}" }

    context "when the provider is not authenticated" do
      before { get_cit }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_cit
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays the heading" do
        expect(response.body).to include("Proceeding 1")
        expect(response.body).to include("Inherent jurisdiction high court injunction")
        expect(unescaped_response_body).to include("What is your client's role in this proceeding?")
      end
    end
  end

  describe "POST /providers/applications/:legal_aid_application_id/client_involvement_type/:proceeding_id" do
    subject(:post_cit) { patch "/providers/applications/#{application.id}/client_involvement_type/#{proceeding.id}", params: }

    let(:params) do
      {
        proceeding: {
          client_involvement_type_ccms_code: "A",
        },
      }
    end

    context "when the provider is not authenticated" do
      before { post_cit }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "when the Continue button is pressed" do
        let(:submit_button) { { continue_button: "Continue" } }

        it "redirects to next page" do
          post_cit
          expect(response).to have_http_status(:redirect)
        end

        context "and pre-existing data is present" do
          before do
            application.update!(
              emergency_cost_override: true,
              emergency_cost_requested: 1001.01,
              emergency_cost_reasons: "some emergency reason",
              substantive_cost_override: true,
              substantive_cost_requested: 2001.01,
              substantive_cost_reasons: "some substantive reason",
            )

            proceeding.update!(
              client_involvement_type_ccms_code: "A",
              client_involvement_type_description: "Applicant, claimant or petitioner",
              accepted_emergency_defaults: true,
              accepted_substantive_defaults: false,
              emergency_level_of_service: 3,
              emergency_level_of_service_name: "Full Representation",
              emergency_level_of_service_stage: 8,
              substantive_level_of_service: 3,
              substantive_level_of_service_name: "Full Representation",
              substantive_level_of_service_stage: 8,
            )
          end

          context "and user changes client involvment type" do
            let(:params) do
              {
                proceeding: {
                  client_involvement_type_ccms_code: "D",
                },
              }
            end

            it "changes the proceeding object's client_involvement_type data" do
              expect { post_cit }.to change { proceeding.reload.attributes.symbolize_keys }
                .from(
                  hash_including(
                    client_involvement_type_ccms_code: "A",
                    client_involvement_type_description: "Applicant, claimant or petitioner",
                  ),
                )
                .to(
                  hash_including(
                    client_involvement_type_ccms_code: "D",
                    client_involvement_type_description: "Defendant or respondent",
                  ),
                )
            end

            it "resets the proceeding object's emergency and substantive default acceptance data" do
              expect { post_cit }.to change { proceeding.reload.attributes.symbolize_keys }
                .from(
                  hash_including(
                    accepted_emergency_defaults: true,
                    accepted_substantive_defaults: false,
                    emergency_level_of_service: 3,
                    emergency_level_of_service_name: "Full Representation",
                    emergency_level_of_service_stage: 8,
                    substantive_level_of_service: 3,
                    substantive_level_of_service_name: "Full Representation",
                    substantive_level_of_service_stage: 8,
                  ),
                )
                .to(
                  hash_including(
                    accepted_emergency_defaults: nil,
                    accepted_substantive_defaults: nil,
                    emergency_level_of_service: nil,
                    emergency_level_of_service_name: nil,
                    emergency_level_of_service_stage: nil,
                    substantive_level_of_service: nil,
                    substantive_level_of_service_name: nil,
                    substantive_level_of_service_stage: nil,
                  ),
                )
            end

            it "resets the legal_aid_application object's emergency and substantive cost override data" do
              expect { post_cit }.to change { application.reload.attributes.symbolize_keys }
                .from(
                  hash_including(
                    emergency_cost_override: true,
                    emergency_cost_requested: 1001.01,
                    emergency_cost_reasons: "some emergency reason",
                    substantive_cost_override: true,
                    substantive_cost_requested: 2001.01,
                    substantive_cost_reasons: "some substantive reason",
                  ),
                )
                .to(
                  hash_including(
                    emergency_cost_override: nil,
                    emergency_cost_requested: nil,
                    emergency_cost_reasons: nil,
                    substantive_cost_override: nil,
                    substantive_cost_requested: nil,
                    substantive_cost_reasons: nil,
                  ),
                )
            end

            it "destroys the proceeding object's emergency and substantive scope_limitations data" do
              expect { post_cit }.to change { proceeding.reload.scope_limitations.count }.from(2).to(0)
            end
          end

          context "and user does NOT change client involvement type" do
            let(:params) do
              {
                proceeding: {
                  client_involvement_type_ccms_code: "A",
                },
              }
            end

            it "does NOT change the proceeding object's client_involvement_type data" do
              expect { post_cit }
                .not_to change {
                  proceeding.reload.slice(:client_involvement_type_ccms_code, :client_involvement_type_description).symbolize_keys
                }
                .from(
                  hash_including(
                    client_involvement_type_ccms_code: "A",
                    client_involvement_type_description: "Applicant, claimant or petitioner",
                  ),
                )
            end

            it "does NOT reset the proceeding object's emergency and substantive default acceptance data" do
              expect { post_cit }
                .not_to change {
                          proceeding.reload.slice(
                            :accepted_substantive_defaults,
                            :accepted_emergency_defaults,
                            :emergency_level_of_service,
                            :emergency_level_of_service_name,
                            :emergency_level_of_service_stage,
                            :substantive_level_of_service,
                            :substantive_level_of_service_name,
                            :substantive_level_of_service_stage,
                          ).symbolize_keys
                        }
              .from(
                hash_including(
                  accepted_emergency_defaults: true,
                  accepted_substantive_defaults: false,
                  emergency_level_of_service: 3,
                  emergency_level_of_service_name: "Full Representation",
                  emergency_level_of_service_stage: 8,
                  substantive_level_of_service: 3,
                  substantive_level_of_service_name: "Full Representation",
                  substantive_level_of_service_stage: 8,
                ),
              )
            end

            it "does NOT reset the legal_aid_application object's emergency and substantive cost override data" do
              expect { post_cit }
                .not_to change {
                          application.reload.slice(
                            :emergency_cost_override,
                            :emergency_cost_requested,
                            :emergency_cost_reasons,
                            :substantive_cost_override,
                            :substantive_cost_requested,
                            :substantive_cost_reasons,
                          ).symbolize_keys
                        }
                .from(
                  hash_including(
                    emergency_cost_override: true,
                    emergency_cost_requested: 1001.01,
                    emergency_cost_reasons: "some emergency reason",
                    substantive_cost_override: true,
                    substantive_cost_requested: 2001.01,
                    substantive_cost_reasons: "some substantive reason",
                  ),
                )
            end

            it "does NOT destroy the proceeding object's emergency and substantive scope_limitations data" do
              expect { post_cit }.not_to change { proceeding.reload.scope_limitations.count }.from(2)
            end
          end
        end
      end

      context "when form submitted with Save as draft button" do
        let(:params) do
          {
            draft_button: "Save and come back later",
          }
        end

        it "redirects to the list of applications" do
          post_cit
          expect(response.body).to redirect_to in_progress_providers_legal_aid_applications_path
        end
      end
    end
  end
end
