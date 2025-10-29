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
      allow(DelegatedFunctionsDateService).to receive(:call).and_return(true)

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
