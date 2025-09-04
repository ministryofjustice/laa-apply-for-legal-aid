require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe WhenContactWasMadeController do
      let(:legal_aid_application) { create(:legal_aid_application, :with_public_law_family_appeal) }
      let(:login_provider) { login_as legal_aid_application.provider }
      let(:smtl) { create(:legal_framework_merits_task_list, :pbm01a_as_applicant, legal_aid_application:) }

      describe "GET /providers/applications/:legal_aid_application_id/when_contact_was_made" do
        subject(:get_request) do
          get providers_legal_aid_application_when_contact_was_made_path(legal_aid_application)
        end

        before do
          login_provider
          get_request
        end

        it "renders successfully" do
          expect(response).to have_http_status(:ok)
        end

        context "when not authenticated" do
          let(:login_provider) { nil }

          it_behaves_like "a provider not authenticated"
        end

        context "with an existing incident" do
          let(:incident) { create(:incident) }
          let(:legal_aid_application) { create(:legal_aid_application, latest_incident: incident) }

          it "renders successfully" do
            expect(response).to have_http_status(:ok)
          end

          it "displays first_contact_date for incident" do
            expect(response.body).to include(incident.first_contact_date.day.to_s)
            expect(response.body).to include(incident.first_contact_date.month.to_s)
            expect(response.body).to include(incident.first_contact_date.year.to_s)
          end
        end
      end

      describe "PATCH /providers/applications/:legal_aid_application_id/when_contact_was_made" do
        subject(:patch_request) do
          patch(
            providers_legal_aid_application_when_contact_was_made_path(legal_aid_application),
            params: params.merge(button_clicked),
          )
        end

        let(:first_contact_date) { 5.days.ago.to_date }
        let(:first_contact_date_3i) { first_contact_date.day }
        let(:params) do
          {
            application_merits_task_incident: {
              "first_contact_date(3i)": first_contact_date_3i,
              "first_contact_date(2i)": first_contact_date.month,
              "first_contact_date(1i)": first_contact_date.year,
            },
          }
        end
        let(:draft_button) { { draft_button: "Save as draft" } }
        let(:button_clicked) { {} }
        let(:incident) { legal_aid_application.reload.latest_incident }

        before do
          allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
          login_provider
        end

        it "creates a new incident with the values entered" do
          expect { patch_request }.to change(::ApplicationMeritsTask::Incident, :count).by(1)
          expect(incident.first_contact_date).to eq(first_contact_date)
        end

        it "sets the task to complete" do
          patch_request
          expect(legal_aid_application.legal_framework_merits_task_list).to have_completed_task(:application, :when_contact_was_made)
        end

        it "redirects to the next page" do
          patch_request
          expect(response).to have_http_status(:redirect)
        end

        context "when not authenticated" do
          let(:login_provider) { nil }

          before { patch_request }

          it_behaves_like "a provider not authenticated"
        end

        context "when incomplete" do
          let(:first_contact_date_3i) { "" }

          it "renders show" do
            patch_request
            expect(response).to have_http_status(:ok)
          end

          it "does not set the task to complete" do
            patch_request
            expect(legal_aid_application.legal_framework_merits_task_list).to have_not_started_task(:application, :when_contact_was_made)
          end
        end

        context "with alpha-numeric date" do
          let(:first_contact_date_3i) { "6s2" }

          it "renders show" do
            patch_request
            expect(response).to have_http_status(:ok)
          end

          it "contains error message" do
            patch_request
            expect(response.body).to include("govuk-error-summary")
            expect(response.body).to include(I18n.t("activemodel.errors.models.application_merits_task/incident.attributes.first_contact_date.date_not_valid"))
          end
        end

        context "when invalid" do
          let(:first_contact_date_3i) { "32" }

          it "renders show" do
            patch_request
            expect(response).to have_http_status(:ok)
          end
        end

        context "when save as draft selected" do
          let(:button_clicked) { draft_button }

          it "redirects to provider draft endpoint" do
            patch_request
            expect(response).to have_http_status(:redirect)
          end

          it "does not set the task to complete" do
            patch_request
            expect(legal_aid_application.legal_framework_merits_task_list).to have_not_started_task(:application, :when_contact_was_made)
          end
        end
      end
    end
  end
end
