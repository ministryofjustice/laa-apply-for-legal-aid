require "rails_helper"

# NOTE: substantive defaults are always not using DF according to code
def da001_applicant_without_df
  {
    success: true,
    requested_params: {
      proceeding_type_ccms_code: "DA001",
      delegated_functions_used: false,
      client_involvement_type: "A",
    },
    default_level_of_service: {
      level: 3,
      name: "Full Representation",
      stage: 8,
    },
    default_scope: {
      code: "AA019",
      meaning: "Injunction FLA-to final hearing",
      description: "As to proceedings under Part IV Family Law Act 1996 limited to all steps up to and including obtaining and serving a final order and in the event of breach leading to the exercise of a power of arrest to representation on the consideration of the breach by the court (but excluding applying for a warrant of arrest, if not attached, and representation in contempt proceedings).",
      additional_params: [],
    },
  }.to_json
end

RSpec.describe "SubstantiveDefaultsController" do
  let(:application) do
    create(:legal_aid_application,
           :with_proceedings,
           :with_delegated_functions_on_proceedings,
           explicit_proceedings: %i[da001],
           df_options: { DA001: [10.days.ago, 10.days.ago] },
           substantive_application_deadline_on: 10.days.from_now)
  end

  let(:proceeding) do
    application.proceedings.first.tap do |proceeding|
      # set data to match what it would be like on first use of page
      proceeding.scope_limitations.where(scope_type: :substantive).destroy_all

      proceeding.update!(
        accepted_substantive_defaults: nil,
        substantive_level_of_service: nil,
        substantive_level_of_service_name: nil,
        substantive_level_of_service_stage: nil,
      )
    end
  end

  let(:provider) { application.provider }
  let(:default_scope_response) { da001_applicant_without_df }

  describe "GET /providers/applications/:legal_aid_application_id/substantive_defaults/:proceeding_id" do
    subject(:get_sd) { get "/providers/applications/#{application.id}/substantive_defaults/#{proceeding.id}" }

    context "when the provider is not authenticated" do
      before { get_sd }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        stub_request(:post, %r{#{Rails.configuration.x.legal_framework_api_host}/proceeding_type_defaults})
          .to_return(
            status: 200,
            body: default_scope_response,
            headers: { "Content-Type" => "application/json; charset=utf-8" },
          )

        login_as provider
        get_sd
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays the proceeding header" do
        expect(page)
          .to have_content("Proceeding 1")
          .and have_content("Inherent jurisdiction high court injunction")
          .and have_content("Do you want to use the default level of service and scope for the substantive application?")
      end

      it "displays the default substantive level of service and scope limitation details" do
        expect(page)
          .to have_content("Default level of service: Full Representation")
          .and have_content("Default scope: Injunction FLA-to final hearing")
          .and have_content("Scope description: As to proceedings under Part IV Family Law Act 1996 limited to all steps up to and including obtaining and serving a final order and in the event of breach leading to the exercise of a power of arrest to representation on the consideration of the breach by the court (but excluding applying for a warrant of arrest, if not attached, and representation in contempt proceedings).")
      end
    end
  end

  describe "POST /providers/applications/:legal_aid_application_id/substantive_defaults/:proceeding_id" do
    subject(:post_sd) { patch "/providers/applications/#{application.id}/substantive_defaults/#{proceeding.id}", params: }

    before do
      stub_request(:post, %r{#{Rails.configuration.x.legal_framework_api_host}/proceeding_type_defaults})
        .to_return(
          status: 200,
          body: default_scope_response,
          headers: { "Content-Type" => "application/json; charset=utf-8" },
        )
    end

    let(:params) do
      {
        proceeding: {
          accepted_substantive_defaults: false,
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
                accepted_substantive_defaults: "true",
              },
            }
          end

          it "sets the default substantive levels of service on the proceeding" do
            expect { post_sd }.to change { proceeding.reload.attributes.symbolize_keys }
              .from(
                hash_including(
                  {
                    substantive_level_of_service: nil,
                    substantive_level_of_service_name: nil,
                    substantive_level_of_service_stage: nil,
                  },
                ),
              ).to(
                hash_including(
                  {
                    substantive_level_of_service: 3,
                    substantive_level_of_service_name: "Full Representation",
                    substantive_level_of_service_stage: 8,
                  },
                ),
              )
          end

          it "adds the default substantive scope limitation to the proceeding" do
            expect { post_sd }.to change { proceeding.scope_limitations.find_by(scope_type: :substantive)&.attributes&.symbolize_keys }
              .from(nil)
              .to(
                hash_including(
                  {
                    scope_type: "substantive",
                    code: "AA019",
                    meaning: "Injunction FLA-to final hearing",
                    description: "As to proceedings under Part IV Family Law Act 1996 limited to all steps up to and including obtaining and serving a final order and in the event of breach leading to the exercise of a power of arrest to representation on the consideration of the breach by the court (but excluding applying for a warrant of arrest, if not attached, and representation in contempt proceedings).",
                    hearing_date: nil,
                  },
                ),
              )
          end

          it "redirects to next page" do
            post_sd
            expect(response).to have_http_status(:redirect)
          end
        end

        context "when the provider does NOT accept the defaults" do
          let(:params) do
            {
              proceeding: {
                accepted_substantive_defaults: "false",
              },
            }
          end

          it "does NOT set the default substantive levels of service" do
            post_sd

            expect(proceeding).to have_attributes(
              substantive_level_of_service: nil,
              substantive_level_of_service_name: nil,
              substantive_level_of_service_stage: nil,
            )
          end

          it "redirects to next page" do
            post_sd
            expect(response).to have_http_status(:redirect)
          end
        end

        context "when the application is a Special Childrens Act application" do
          let(:application) { create(:legal_aid_application, :with_multiple_sca_proceedings) }
          let(:params) do
            {
              proceeding: {
                accepted_substantive_defaults: "true",
              },
            }
          end

          it "redirects to next page" do
            post_sd
            expect(response).to have_http_status(:redirect)
          end

          it "sets the default substantive levels of service on the proceeding" do
            expect { post_sd }.to change { proceeding.reload.attributes.symbolize_keys }
                                    .from(
                                      hash_including(
                                        {
                                          substantive_level_of_service: nil,
                                          substantive_level_of_service_name: nil,
                                          substantive_level_of_service_stage: nil,
                                        },
                                      ),
                                    ).to(
                                      hash_including(
                                        {
                                          substantive_level_of_service: 3,
                                          substantive_level_of_service_name: "Full Representation",
                                          substantive_level_of_service_stage: 8,
                                        },
                                      ),
                                    )
          end
        end

        context "when the user has already answered this question" do
          context "and changes answer from No to Yes" do
            let(:params) do
              {
                proceeding: {
                  accepted_substantive_defaults: "true",
                },
              }
            end

            before do
              # set a value which will be updated even though only some proceedings have a choice of level of service other than default, so fake that here
              proceeding.update!(
                accepted_substantive_defaults: false,
                substantive_level_of_service: 33,
                substantive_level_of_service_name: "Not a real level of service",
                substantive_level_of_service_stage: 88,
              )

              # When user has prevously added a non-default scope limitation
              proceeding.scope_limitations.create!(
                scope_type: :substantive,
                code: "CV027",
                meaning: "Hearing/Adjournment",
                description: "Limited to all steps (including any adjournment thereof) up to and including the hearing on",
                hearing_date: Time.zone.tomorrow,
              )
            end

            it "changes proceeding attributes to default level of service" do
              expect { post_sd }.to change { proceeding.reload.attributes.symbolize_keys }
                 .from(
                   hash_including(
                     {
                       accepted_substantive_defaults: false,
                       substantive_level_of_service: 33,
                       substantive_level_of_service_name: "Not a real level of service",
                       substantive_level_of_service_stage: 88,
                     },
                   ),
                 ).to(
                   hash_including(
                     {
                       accepted_substantive_defaults: true,
                       substantive_level_of_service: 3,
                       substantive_level_of_service_name: "Full Representation",
                       substantive_level_of_service_stage: 8,
                     },
                   ),
                 )
            end

            it "replaces user-chosen scope limitation with defaults" do
              expect { post_sd }.to change { proceeding.scope_limitations.where(scope_type: :substantive).first.attributes.symbolize_keys }
                .from(
                  hash_including(
                    {
                      scope_type: "substantive",
                      code: "CV027",
                      meaning: "Hearing/Adjournment",
                      description: "Limited to all steps (including any adjournment thereof) up to and including the hearing on",
                      hearing_date: instance_of(Date),
                    },
                  ),
                ).to(
                  hash_including(
                    {
                      scope_type: "substantive",
                      code: "AA019",
                      meaning: "Injunction FLA-to final hearing",
                      description: "As to proceedings under Part IV Family Law Act 1996 limited to all steps up to and including obtaining and serving a final order and in the event of breach leading to the exercise of a power of arrest to representation on the consideration of the breach by the court (but excluding applying for a warrant of arrest, if not attached, and representation in contempt proceedings).",
                      hearing_date: nil,
                    },
                  ),
                )
            end
          end

          context "and changes their answer from Yes to No" do
            let(:params) do
              {
                proceeding: {
                  accepted_substantive_defaults: "false",
                },
              }
            end

            before do
              # set a value which will be updated even though only some proceedings have a choice of level of service other than default, so fake that here
              proceeding.update!(
                accepted_substantive_defaults: true,
                substantive_level_of_service: 11,
                substantive_level_of_service_name: "My pretend default level of service",
                substantive_level_of_service_stage: 99,
              )

              # When user has prevously added/accepted the default scope limitation
              proceeding.scope_limitations.create!(
                scope_type: "substantive",
                code: "AA019",
                meaning: "Injunction FLA-to final hearing",
                description: "As to proceedings under Part IV Family Law Act 1996 limited to all steps up to and including obtaining and serving a final order and in the event of breach leading to the exercise of a power of arrest to representation on the consideration of the breach by the court (but excluding applying for a warrant of arrest, if not attached, and representation in contempt proceedings).",
                hearing_date: nil,
              )
            end

            it "nullifies default level of service proceeding attributes - in preparation for picking a non-default level of service" do
              expect { post_sd }.to change { proceeding.reload.attributes.symbolize_keys }
                 .from(
                   hash_including(
                     {
                       accepted_substantive_defaults: true,
                       substantive_level_of_service: 11,
                       substantive_level_of_service_name: "My pretend default level of service",
                       substantive_level_of_service_stage: 99,
                     },
                   ),
                 ).to(
                   hash_including(
                     {
                       accepted_substantive_defaults: false,
                       substantive_level_of_service: nil,
                       substantive_level_of_service_name: nil,
                       substantive_level_of_service_stage: nil,
                     },
                   ),
                 )
            end

            it "removes existing substantive default scope limitation" do
              expect { post_sd }.to change(proceeding.scope_limitations.where(scope_type: :substantive), :count).from(1).to(0)
            end
          end

          context "and does NOT change their answer from No" do
            let(:params) do
              {
                proceeding: {
                  accepted_substantive_defaults: "false",
                },
              }
            end

            before do
              # set a value which will be updated even though only some proceedings have a choice of level of service other than default, so fake that here
              proceeding.update!(accepted_substantive_defaults: false,
                                 substantive_level_of_service: 33,
                                 substantive_level_of_service_name: "Not a real level of service",
                                 substantive_level_of_service_stage: 88)

              # When user has prevously added a non-default scope limitation
              proceeding.scope_limitations.create!(
                scope_type: :substantive,
                code: "CV027",
                meaning: "Hearing/Adjournment",
                description: "Limited to all steps (including any adjournment thereof) up to and including the hearing on",
                hearing_date: Time.zone.tomorrow,
              )
            end

            it "does NOT change proceeding attributes from what they were" do
              expect { post_sd }.not_to change { proceeding.reload.attributes.symbolize_keys }
                 .from(
                   hash_including(
                     {
                       accepted_substantive_defaults: false,
                       substantive_level_of_service: 33,
                       substantive_level_of_service_name: "Not a real level of service",
                       substantive_level_of_service_stage: 88,
                     },
                   ),
                 )
            end

            it "does NOT remove the existing scope limitation" do
              expect { post_sd }.not_to change(proceeding.scope_limitations.where(scope_type: :substantive), :count).from(1)

              expect(proceeding.scope_limitations.where(scope_type: :substantive).first)
                .to have_attributes(
                  scope_type: "substantive",
                  code: "CV027",
                  meaning: "Hearing/Adjournment",
                  description: "Limited to all steps (including any adjournment thereof) up to and including the hearing on",
                  hearing_date: Time.zone.tomorrow,
                )
            end
          end

          context "and does NOT change their answer from Yes" do
            let(:params) do
              {
                proceeding: {
                  accepted_substantive_defaults: "true",
                },
              }
            end

            before do
              # set a value which will be updated even though only some proceedings have a choice of level of service other than default, so fake that here
              proceeding.update!(
                accepted_substantive_defaults: true,
                substantive_level_of_service: 11,
                substantive_level_of_service_name: "My pretend default level of service",
                substantive_level_of_service_stage: 99,
              )

              # When user has prevously added/accepted a default scope limitation
              proceeding.scope_limitations.create!(
                scope_type: "substantive",
                code: "AA019",
                meaning: "Injunction FLA-to final hearing",
                description: "As to proceedings under Part IV Family Law Act 1996 limited to all steps up to and including obtaining and serving a final order and in the event of breach leading to the exercise of a power of arrest to representation on the consideration of the breach by the court (but excluding applying for a warrant of arrest, if not attached, and representation in contempt proceedings).",
                hearing_date: nil,
              )
            end

            it "does NOT change proceeding attributes from what they were" do
              expect { post_sd }.not_to change { proceeding.reload.attributes.symbolize_keys }
                 .from(
                   hash_including(
                     {
                       accepted_substantive_defaults: true,
                       substantive_level_of_service: 11,
                       substantive_level_of_service_name: "My pretend default level of service",
                       substantive_level_of_service_stage: 99,
                     },
                   ),
                 )
            end

            it "does NOT remove the existing scope limitation" do
              expect { post_sd }.not_to change(proceeding.scope_limitations.where(scope_type: :substantive), :count).from(1)

              expect(proceeding.scope_limitations.where(scope_type: :substantive).first)
                .to have_attributes(
                  scope_type: "substantive",
                  code: "AA019",
                  meaning: "Injunction FLA-to final hearing",
                  description: "As to proceedings under Part IV Family Law Act 1996 limited to all steps up to and including obtaining and serving a final order and in the event of breach leading to the exercise of a power of arrest to representation on the consideration of the breach by the court (but excluding applying for a warrant of arrest, if not attached, and representation in contempt proceedings).",
                  hearing_date: nil,
                )
            end
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
              expect(response).to redirect_to(providers_legal_aid_application_substantive_level_of_service_path(application.id))
            end
          end
        end
      end
    end
  end
end
