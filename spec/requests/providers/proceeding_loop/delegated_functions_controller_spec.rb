require "rails_helper"

RSpec.describe "DelegatedFunctionsController" do
  let(:application) { create(:legal_aid_application, :with_proceedings) }
  let(:application_id) { application.id }
  let(:proceeding) { application.proceedings.first }
  let(:proceeding_id) { proceeding.id }
  let(:provider) { application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/delegated_functions/:proceeding_id" do
    subject(:get_df) { get "/providers/applications/#{application_id}/delegated_functions/#{proceeding_id}" }

    context "when the provider is not authenticated" do
      before { get_df }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_df
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      context "with a non-Special children act (non-SCA) proceeding" do
        it "displays expected header, question and [not] hint" do
          expect(response.body)
            .to include("Proceeding 1")
            .and include("Inherent jurisdiction high court injunction")
            .and include("Have you used delegated functions for this proceeding?")

          expect(response.body).not_to include("Answer this, even for special children act")
        end
      end

      context "with an Special children act (SCA) proceeding" do
        let(:application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[pb003], set_lead_proceeding: :pb003) }

        it "displays expected header, question and SCA hint" do
          expect(response.body)
            .to include("Proceeding 1")
            .and include("Child assessment order")
            .and include("Have you used delegated functions for this proceeding?")
            .and include("Answer this, even for special children act")
        end
      end
    end
  end

  describe "POST /providers/applications/:legal_aid_application_id/delegated_functions/:proceeding_id" do
    subject(:post_df) { patch "/providers/applications/#{application_id}/delegated_functions/#{proceeding_id}", params: }

    before { allow(DelegatedFunctionsDateService).to receive(:call).and_return(true) }

    let(:params) do
      {
        proceeding: {
          used_delegated_functions: false,
        },
      }
    end

    context "when the provider is not authenticated" do
      before { post_df }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "when the Continue button is pressed" do
        let(:submit_button) { { continue_button: "Continue" } }

        context "and the proceeding has used delegated functions" do
          let(:params) do
            {
              proceeding: {
                used_delegated_functions: true,
                used_delegated_functions_on: 5.days.ago.to_date.to_s(:date_picker),
              },
            }
          end

          it "redirects to next page" do
            post_df
            expect(response.body).to redirect_to(providers_legal_aid_application_emergency_default_path(application_id, proceeding_id))
          end

          it "calls the DelegatedFunctionsDateService service" do
            post_df
            expect(DelegatedFunctionsDateService).to have_received(:call).once
          end
        end

        context "and the special children act proceeding has used delegated functions" do
          let(:application) { create(:legal_aid_application, :with_multiple_sca_proceedings) }

          let(:params) do
            {
              proceeding: {
                used_delegated_functions: true,
                used_delegated_functions_on: 5.days.ago.to_date.to_s(:date_picker),
              },
            }
          end

          it "redirects to the substantive defaults page" do
            post_df
            expect(response.body).to redirect_to(providers_legal_aid_application_substantive_default_path(application_id, proceeding_id))
          end

          it "does not call the DelegatedFunctionsDateService service" do
            post_df
            expect(DelegatedFunctionsDateService).not_to have_received(:call)
          end
        end

        context "and the proceeding has not used delegated functions" do
          it "redirects to next page" do
            post_df
            expect(response.body).to redirect_to(providers_legal_aid_application_substantive_default_path(application_id, proceeding_id))
          end
        end

        context "and the date is more than a month old" do
          let(:params) do
            {
              proceeding: {
                used_delegated_functions: true,
                used_delegated_functions_on: 35.days.ago.to_date.to_s(:date_picker),
              },
            }
          end

          it "redirects to the confirmation page" do
            post_df
            expect(response.body).to redirect_to(providers_legal_aid_application_confirm_delegated_functions_date_path(application_id, proceeding_id))
          end

          context "when provider changes yes to no" do
            before do
              proceeding.update!(
                used_delegated_functions: true,
                used_delegated_functions_on: 1.day.ago.to_date,
                used_delegated_functions_reported_on: Date.current,
              )
            end

            let(:params) do
              {
                proceeding: {
                  used_delegated_functions: "false",
                },
              }
            end

            it "updates the proceeding to remove the previous values" do
              expect { post_df }
                .to change { proceeding.reload.attributes.symbolize_keys }
                  .from(
                    hash_including(
                      {
                        used_delegated_functions: true,
                        used_delegated_functions_on: 1.day.ago.to_date,
                        used_delegated_functions_reported_on: Date.current,
                      },
                    ),
                  ).to(
                    hash_including(
                      {
                        used_delegated_functions: false,
                        used_delegated_functions_on: nil,
                        used_delegated_functions_reported_on: nil,
                      },
                    ),
                  )
            end
          end
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

          context "and user changes Yes to No" do
            before do
              proceeding.update!(
                used_delegated_functions: true,
                used_delegated_functions_on: Time.zone.yesterday,
                used_delegated_functions_reported_on: Time.zone.yesterday,
              )
            end

            let(:params) do
              {
                proceeding: {
                  used_delegated_functions: "false",
                },
              }
            end

            it "changes the proceeding object's used_delegated_functions related data" do
              expect { post_df }.to change { proceeding.reload.attributes.symbolize_keys }
                .from(
                  hash_including(
                    used_delegated_functions: true,
                    used_delegated_functions_on: Time.zone.yesterday,
                    used_delegated_functions_reported_on: Time.zone.yesterday,
                  ),
                )
                .to(
                  hash_including(
                    used_delegated_functions: false,
                    used_delegated_functions_on: nil,
                    used_delegated_functions_reported_on: nil,
                  ),
                )
            end

            it "resets the proceeding object's emergency and substantive default acceptance data" do
              expect { post_df }.to change { proceeding.reload.attributes.symbolize_keys }
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
              expect { post_df }.to change { application.reload.attributes.symbolize_keys }
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
              expect { post_df }.to change { proceeding.reload.scope_limitations.count }.from(2).to(0)
            end
          end

          context "and user changes No to Yes" do
            before do
              proceeding.update!(
                used_delegated_functions: false,
                used_delegated_functions_on: nil,
                used_delegated_functions_reported_on: nil,
              )
            end

            let(:params) do
              {
                proceeding: {
                  used_delegated_functions: "true",
                  used_delegated_functions_on: Time.zone.yesterday.to_s(:date_picker),
                },
              }
            end

            it "changes the proceeding object's used_delegated_functions related data" do
              expect { post_df }.to change { proceeding.reload.attributes.symbolize_keys }
                .from(
                  hash_including(
                    used_delegated_functions: false,
                    used_delegated_functions_on: nil,
                    used_delegated_functions_reported_on: nil,
                  ),
                )
                .to(
                  hash_including(
                    used_delegated_functions: true,
                    used_delegated_functions_on: Time.zone.yesterday,
                    used_delegated_functions_reported_on: Time.zone.today,
                  ),
                )
            end

            it "resets the proceeding object's emergency and substantive default acceptance data" do
              expect { post_df }.to change { proceeding.reload.attributes.symbolize_keys }
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
              expect { post_df }.to change { application.reload.attributes.symbolize_keys }
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
              expect { post_df }.to change { proceeding.reload.scope_limitations.count }.from(2).to(0)
            end
          end

          context "and user changes used_delegated_functions on date" do
            before do
              proceeding.update!(
                used_delegated_functions: true,
                used_delegated_functions_on: 1.week.ago.to_date,
                used_delegated_functions_reported_on: 1.week.ago.to_date,
              )
            end

            let(:params) do
              {
                proceeding: {
                  used_delegated_functions: "true",
                  used_delegated_functions_on: Time.zone.yesterday.to_s(:date_picker),
                },
              }
            end

            it "changes the proceeding object's uaed_delegated_functions related data" do
              expect { post_df }.to change { proceeding.reload.attributes.symbolize_keys }
                .from(
                  hash_including(
                    used_delegated_functions: true,
                    used_delegated_functions_on: 1.week.ago.to_date,
                    used_delegated_functions_reported_on: 1.week.ago.to_date,
                  ),
                )
                .to(
                  hash_including(
                    used_delegated_functions: true,
                    used_delegated_functions_on: Time.zone.yesterday,
                    used_delegated_functions_reported_on: Time.zone.today,
                  ),
                )
            end

            it "does NOT reset the proceeding object's emergency and substantive default acceptance data" do
              expect { post_df }
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
              expect { post_df }
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
              expect { post_df }.not_to change { proceeding.reload.scope_limitations.count }.from(2)
            end
          end

          context "and user does NOT change any data" do
            before do
              proceeding.update!(
                used_delegated_functions: true,
                used_delegated_functions_on: 1.week.ago.to_date,
                used_delegated_functions_reported_on: 1.week.ago.to_date,
              )
            end

            let(:params) do
              {
                proceeding: {
                  used_delegated_functions: "true",
                },
              }
            end

            it "does NOT change the proceeding object's uaed_delegated_functions related data" do
              expect { post_df }
                .not_to change {
                  proceeding.reload.slice(:used_delegated_functions, :used_delegated_functions_on, :used_delegated_functions_reported_on).symbolize_keys
                }
                .from(
                  hash_including(
                    used_delegated_functions: true,
                    used_delegated_functions_on: 1.week.ago.to_date,
                    used_delegated_functions_reported_on: 1.week.ago.to_date,
                  ),
                )
            end

            it "does NOT reset the proceeding object's emergency and substantive default acceptance data" do
              expect { post_df }
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
              expect { post_df }
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
              expect { post_df }.not_to change { proceeding.reload.scope_limitations.count }.from(2)
            end
          end
        end

        context "when checking answers" do
          let(:application) do
            create(
              :legal_aid_application,
              :with_applicant_and_address_lookup,
              :checking_applicant_details,
              :with_proceedings,
              :with_delegated_functions_on_proceedings,
              explicit_proceedings: %i[da001 se013],
              df_options: { DA001: [10.days.ago, 10.days.ago], SE013: nil },
              substantive_application_deadline_on: 10.days.from_now,
            ).reload
          end

          context "and the date is within the last month" do
            let(:params) do
              {
                proceeding: {
                  used_delegated_functions: true,
                  used_delegated_functions_on: 28.days.ago.to_date.to_s(:date_picker),
                },
              }
            end

            it "continues through the sub flow" do
              post_df
              expect(response).to redirect_to(providers_legal_aid_application_emergency_default_path(application_id))
            end
          end

          context "and the date is more than a month old" do
            let(:params) do
              {
                proceeding: {
                  used_delegated_functions: true,
                  used_delegated_functions_on: 35.days.ago.to_date.to_s(:date_picker),
                },
              }
            end

            it "redirects to confirm delegated functions date page" do
              post_df
              expect(response).to redirect_to(providers_legal_aid_application_confirm_delegated_functions_date_path(application_id, proceeding_id))
            end
          end

          context "and the proceeding has used delegated functions" do
            let(:params) do
              {
                proceeding: {
                  used_delegated_functions: true,
                  used_delegated_functions_on: 5.days.ago.to_date.to_s(:date_picker),
                },
              }
            end

            it "redirects to next page" do
              post_df
              expect(response.body).to redirect_to(providers_legal_aid_application_emergency_default_path(application_id, proceeding_id))
            end
          end

          context "and the proceeding has not used delegated functions" do
            let(:params) do
              {
                proceeding: {
                  used_delegated_functions: false,
                },
              }
            end

            it "redirects to next page" do
              post_df
              expect(response.body).to redirect_to(providers_legal_aid_application_substantive_default_path(application_id, proceeding_id))
            end
          end
        end
      end
    end
  end
end
