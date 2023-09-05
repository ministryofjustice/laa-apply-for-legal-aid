require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe OpponentOrganisationsController, :vcr do
      let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8) }
      let(:login_provider) { login_as legal_aid_application.provider }
      let(:smtl) { create(:legal_framework_merits_task_list, legal_aid_application:) }
      let(:proceeding) { laa.proceedings.detect { |p| p.ccms_code == "SE014" } }

      describe "new: GET /providers/applications/:legal_aid_application_id/opponent_organisations/new" do
        subject(:get_new_opponent) { get new_providers_legal_aid_application_opponent_organisation_path(legal_aid_application) }

        context "when authenticated" do
          before do
            login_provider
            get_new_opponent
          end

          it "returns success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the form to add new opponent organisations" do
            expect(response.body).to include("Organisation name")
            expect(response.body).to include("Organisation type")
          end
        end

        context "when unauthenticated" do
          before { get_new_opponent }

          it_behaves_like "a provider not authenticated"
        end
      end

      describe "show: GET /providers/applications/:legal_aid_application_id/opponent_organisations/:opponent_id" do
        subject(:get_existing_opponent) { get providers_legal_aid_application_opponent_organisation_path(legal_aid_application, opponent) }

        let(:opponent) { create(:opponent, :for_organisation, legal_aid_application:) }

        context "when authenticated" do
          before do
            login_provider
            get_existing_opponent
          end

          it "returns success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays opponent's details" do
            expect(response.body).to include(html_compare(opponent.name))
            expect(response.body).to include(html_compare(opponent.ccms_type_text))
          end
        end

        context "when unauthenticated" do
          before { get_existing_opponent }

          it_behaves_like "a provider not authenticated"
        end
      end

      describe "update: PATCH /providers/applications/:legal_aid_application_id/opponent_organisations/:opponent_id" do
        subject(:patch_organisation) do
          patch(
            providers_legal_aid_application_opponent_organisation_path(legal_aid_application, opponent),
            params: params.merge(button_clicked),
          )
        end

        let!(:opponent) { create(:opponent, :for_organisation, legal_aid_application:, organisation_name: "Mid Bedfordshire Council", organisation_ccms_type_code: "GOVT", organisation_ccms_type_text: "Government Department") }

        let(:params) do
          {
            application_merits_task_opponent: {
              name: "Central Bedfordshire Council",
              organisation_type_ccms_code: "LA",
            },
          }
        end

        let(:draft_button) { { draft_button: "Save as draft" } }
        let(:button_clicked) { {} }

        before do
          allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
          login_provider
        end

        it "amends the opponent opposable organisation with the values entered" do
          expect { patch_organisation }.not_to change(::ApplicationMeritsTask::Organisation, :count)
          opponent.opposable.reload
          expect(opponent.opposable.name).to eql "Central Bedfordshire Council"
          expect(opponent.opposable.ccms_type_code).to eql "LA"
        end

        it "sets the task to complete" do
          patch_organisation
          expect(legal_aid_application.legal_framework_merits_task_list).to have_completed_task(:application, :opponent_name)
        end

        it "redirects to the has another opponent question" do
          patch_organisation
          expect(response).to redirect_to(providers_legal_aid_application_has_other_opponent_path(legal_aid_application))
        end

        context "when not authenticated" do
          let(:login_provider) { nil }

          before { patch_organisation }

          it_behaves_like "a provider not authenticated"
        end

        context "when incomplete" do
          let(:params) do
            {
              application_merits_task_opponent: {
                name: "",
                organisation_type_ccms_code: "",
              },
            }
          end

          it "renders show" do
            patch_organisation
            expect(response).to have_http_status(:ok)
          end

          it "contains error message" do
            patch_organisation
            expect(response.body).to include("govuk-error-summary")
            .and include(html_compare("Enter the organisation's name"))
            .and include(html_compare("Select the organisation's type"))
          end

          it "does not set the task to complete" do
            patch_organisation
            expect(legal_aid_application.legal_framework_merits_task_list).to have_task_in_state(:application, :opponent_name, :not_started)
          end
        end

        context "when save as draft selected" do
          let(:button_clicked) { draft_button }

          it "redirects to provider draft endpoint" do
            patch_organisation
            expect(response).to redirect_to providers_legal_aid_applications_path
          end

          it "does not set the task to complete" do
            patch_organisation
            expect(legal_aid_application.legal_framework_merits_task_list.serialized_data).to match(/name: :opponent_name\n\s+dependencies: \*\d+\n\s+state: :not_started/)
          end
        end
      end
    end
  end
end
