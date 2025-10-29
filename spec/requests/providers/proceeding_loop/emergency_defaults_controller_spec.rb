require "rails_helper"

def da001_applicant_with_df
  {
    success: true,
    requested_params: {
      proceeding_type_ccms_code: "DA001",
      delegated_functions_used: true,
      client_involvement_type: "A",
    },
    default_level_of_service: {
      level: 3,
      name: "Full Representation",
      stage: 8,
    },
    default_scope: {
      code: "CV117",
      meaning: "Interim order inc. return date",
      description: "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.",
      additional_params: [],
    },
  }.to_json
end

def da001_defendant_with_df
  {
    success: true,
    requested_params: {
      proceeding_type_ccms_code: "DA001",
      delegated_functions_used: true,
      client_involvement_type: "D",
    },
    default_level_of_service: {
      level: 3,
      name: "Full Representation",
      stage: 8,
    },
    default_scope: {
      code: "CV118",
      meaning: "Hearing",
      description: "Limited to all steps up to and including the hearing on [see additional limitation notes]",
      additional_params: [
        {
          name: "hearing_date",
          type: "date",
          mandatory: true,
        },
      ],
    },
  }.to_json
end

def fake_da001_with_limitation_note
  {
    success: true,
    requested_params: {
      proceeding_type_ccms_code: "DA001",
      delegated_functions_used: true,
      client_involvement_type: "D",
    },
    default_level_of_service: {
      level: 3,
      name: "Full Representation",
      stage: 8,
    },
    default_scope: {
      code: "APL13",
      meaning: "Hearing",
      description: "Limited to all steps up to and including the hearing on [see additional limitation notes]",
      additional_params: [
        {
          name: "limitation_note",
          type: "text",
          mandatory: true,
        },
      ],
    },
  }.to_json
end

RSpec.describe "EmergencyDefaultsController" do
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

      app.proceedings.first.scope_limitations.destroy_all
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
        stub_request(:post, %r{#{Rails.configuration.x.legal_framework_api_host}/proceeding_type_defaults})
          .to_return(
            status: 200,
            body: default_scope_response,
            headers: { "Content-Type" => "application/json; charset=utf-8" },
          )

        login_as provider
        get_sd
      end

      let(:default_scope_response) { da001_applicant_with_df }

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays the proceeding header" do
        expect(page)
          .to have_content("Proceeding 1")
          .and have_content("Inherent jurisdiction high court injunction")
          .and have_content("Do you want to use the default level of service and scope for the emergency application?")
      end

      context "when default scope limitations includes hearing_date as an additional_params" do
        let(:default_scope_response) { da001_defendant_with_df }

        it "renders the hearing date partial" do
          expect(response).to render_template("shared/scope_limitations/_hearing_date")
        end
      end

      context "when default scope limitations includes limitation_note as an additional_params" do
        # NOTE: there may not be a default scope with limitation_note additional param
        let(:default_scope_response) { fake_da001_with_limitation_note }

        it "renders the hearing date partial" do
          expect(response).to render_template("shared/scope_limitations/_limitation_note")
        end
      end
    end
  end

  describe "POST /providers/applications/:legal_aid_application_id/emergency_defaults/:proceeding_id" do
    subject(:post_sd) { patch "/providers/applications/#{application.id}/emergency_defaults/#{proceeding.id}", params: }

    before do
      stub_request(:post, %r{#{Rails.configuration.x.legal_framework_api_host}/proceeding_type_defaults})
        .to_return(
          status: 200,
          body: default_scope_response,
          headers: { "Content-Type" => "application/json; charset=utf-8" },
        )
    end

    let(:default_scope_response) { da001_applicant_with_df }

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

          it "redirects to next page" do
            post_sd
            expect(response.body).to redirect_to(providers_legal_aid_application_substantive_default_path(application.id, proceeding.id))
          end
        end

        context "when the provider does NOT accept the defaults" do
          let(:params) do
            {
              proceeding: {
                accepted_emergency_defaults: false,
              },
            }
          end

          it "does NOT set the default emergency levels of service" do
            post_sd

            expect(proceeding).to have_attributes(
              emergency_level_of_service: nil,
              emergency_level_of_service_name: nil,
              emergency_level_of_service_stage: nil,
            )
          end

          it "redirects to next page" do
            post_sd
            expect(response.body).to redirect_to(providers_legal_aid_application_emergency_level_of_service_path(application.id, proceeding.id))
          end
        end

        context "when the user has already answered this question" do
          context "and changes answer from No to Yes" do
            let(:params) do
              {
                proceeding: {
                  accepted_emergency_defaults: "true",
                },
              }
            end

            before do
              # set a value which will be updated even though only some proceedings have a choice of level of service other than default, so fake that here
              proceeding.update!(
                accepted_emergency_defaults: false,
                emergency_level_of_service: 33,
                emergency_level_of_service_name: "Not a real level of service",
                emergency_level_of_service_stage: 88,
              )

              # When user has prevously added a non-default scope limitation
              proceeding.scope_limitations.create!(
                scope_type: :emergency,
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
                       accepted_emergency_defaults: false,
                       emergency_level_of_service: 33,
                       emergency_level_of_service_name: "Not a real level of service",
                       emergency_level_of_service_stage: 88,
                     },
                   ),
                 ).to(
                   hash_including(
                     {
                       accepted_emergency_defaults: true,
                       emergency_level_of_service: 3,
                       emergency_level_of_service_name: "Full Representation",
                       emergency_level_of_service_stage: 8,
                     },
                   ),
                 )
            end

            it "replaces user-chosen scope limitation with defaults" do
              expect { post_sd }.to change { proceeding.scope_limitations.where(scope_type: :emergency).first.attributes.symbolize_keys }
                .from(
                  hash_including(
                    {
                      scope_type: "emergency",
                      code: "CV027",
                      meaning: "Hearing/Adjournment",
                      description: "Limited to all steps (including any adjournment thereof) up to and including the hearing on",
                      hearing_date: instance_of(Date),
                    },
                  ),
                ).to(
                  hash_including(
                    {
                      scope_type: "emergency",
                      code: "CV117",
                      meaning: "Interim order inc. return date",
                      description: "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.",
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
                  accepted_emergency_defaults: "false",
                },
              }
            end

            before do
              # set a value which will be updated even though only some proceedings have a choice of level of service other than default, so fake that here
              proceeding.update!(
                accepted_emergency_defaults: true,
                emergency_level_of_service: 11,
                emergency_level_of_service_name: "My pretend default level of service",
                emergency_level_of_service_stage: 99,
              )

              # When user has prevously added/accepted the default scope limitation
              proceeding.scope_limitations.create!(
                scope_type: "emergency",
                code: "CV117",
                meaning: "Interim order inc. return date",
                description: "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.",
                hearing_date: nil,
              )
            end

            it "nullifies default level of service proceeding attributes - in preparation for picking a non-default level of service" do
              expect { post_sd }.to change { proceeding.reload.attributes.symbolize_keys }
                 .from(
                   hash_including(
                     {
                       accepted_emergency_defaults: true,
                       emergency_level_of_service: 11,
                       emergency_level_of_service_name: "My pretend default level of service",
                       emergency_level_of_service_stage: 99,
                     },
                   ),
                 ).to(
                   hash_including(
                     {
                       accepted_emergency_defaults: false,
                       emergency_level_of_service: nil,
                       emergency_level_of_service_name: nil,
                       emergency_level_of_service_stage: nil,
                     },
                   ),
                 )
            end

            it "removes existing emergency default scope limitation" do
              expect { post_sd }.to change(proceeding.scope_limitations.where(scope_type: :emergency), :count).from(1).to(0)
            end
          end

          context "and does NOT change their answer from No" do
            let(:params) do
              {
                proceeding: {
                  accepted_emergency_defaults: "false",
                },
              }
            end

            before do
              # set a value which will be updated even though only some proceedings have a choice of level of service other than default, so fake that here
              proceeding.update!(accepted_emergency_defaults: false,
                                 emergency_level_of_service: 33,
                                 emergency_level_of_service_name: "Not a real level of service",
                                 emergency_level_of_service_stage: 88)

              # When user has prevously added a non-default scope limitation
              proceeding.scope_limitations.create!(
                scope_type: :emergency,
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
                       accepted_emergency_defaults: false,
                       emergency_level_of_service: 33,
                       emergency_level_of_service_name: "Not a real level of service",
                       emergency_level_of_service_stage: 88,
                     },
                   ),
                 )
            end

            it "does NOT remove the existing scope limitation" do
              expect { post_sd }.not_to change(proceeding.scope_limitations.where(scope_type: :emergency), :count).from(1)

              expect(proceeding.scope_limitations.where(scope_type: :emergency).first)
                .to have_attributes(
                  scope_type: "emergency",
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
                  accepted_emergency_defaults: "true",
                },
              }
            end

            before do
              # set a value which will be updated even though only some proceedings have a choice of level of service other than default, so fake that here
              proceeding.update!(
                accepted_emergency_defaults: true,
                emergency_level_of_service: 11,
                emergency_level_of_service_name: "My pretend default level of service",
                emergency_level_of_service_stage: 99,
              )

              # When user has prevously added/accepted a default scope limitation
              proceeding.scope_limitations.create!(
                scope_type: "emergency",
                code: "CV117",
                meaning: "Interim order inc. return date",
                description: "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.",
                hearing_date: nil,
              )
            end

            it "does NOT change proceeding attributes from what they were" do
              expect { post_sd }.not_to change { proceeding.reload.attributes.symbolize_keys }
                 .from(
                   hash_including(
                     {
                       accepted_emergency_defaults: true,
                       emergency_level_of_service: 11,
                       emergency_level_of_service_name: "My pretend default level of service",
                       emergency_level_of_service_stage: 99,
                     },
                   ),
                 )
            end

            it "does NOT remove the existing scope limitation" do
              expect { post_sd }.not_to change(proceeding.scope_limitations.where(scope_type: :emergency), :count).from(1)

              expect(proceeding.scope_limitations.where(scope_type: :emergency).first)
                .to have_attributes(
                  scope_type: "emergency",
                  code: "CV117",
                  meaning: "Interim order inc. return date",
                  description: "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.",
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
              expect(response).to redirect_to(providers_legal_aid_application_emergency_level_of_service_path(application.id))
            end
          end
        end
      end
    end
  end
end
