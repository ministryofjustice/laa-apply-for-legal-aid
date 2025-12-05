require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe OpponentExistingOrganisationsController, vcr: { cassette_name: "lfa_organisations_all", allow_playback_repeats: true } do
      let(:legal_aid_application) { create(:legal_aid_application) }
      let(:provider) { legal_aid_application.provider }

      describe "index: GET /providers/applications/:legal_aid_application_id/opponent_existing_organisations" do
        subject(:index_request) { get providers_legal_aid_application_opponent_existing_organisations_path(legal_aid_application) }

        context "when the provider is not authenticated" do
          before { index_request }

          it_behaves_like "a provider not authenticated"
        end

        context "when the provider is authenticated" do
          before do
            login_as provider
          end

          it "returns expected template with http success" do
            index_request
            expect(response)
              .to have_http_status(:ok)
              .and render_template("providers/application_merits_task/opponent_existing_organisations/index")
          end

          it "contains expected number of organisations" do
            index_request
            doc = Nokogiri::HTML(response.body)
            expect(doc.css(".organisation-item").length).to be >= 1196
          end

          it "displays no errors" do
            index_request
            expect(response.body).not_to include("govuk-input--error")
            expect(response.body).not_to include("govuk-form-group--error")
          end
        end
      end

      describe "create: POST /providers/applications/:legal_aid_application_id/legal_aid_application_id/opponent_existing_organisations" do
        subject(:create_request) do
          post(
            providers_legal_aid_application_opponent_existing_organisations_path(legal_aid_application),
            params:,
          )
        end

        let(:params) { { continue_button: "Continue" } }

        before do
          login_as provider
        end

        it "renders index" do
          create_request
          expect(response).to have_http_status(:ok)
        end

        it "displays errors" do
          create_request
          expect(response.body).to include("govuk-input--error")
          expect(response.body).to include("govuk-form-group--error")
        end

        context "with an organisation id" do
          let(:params) do
            {
              id: "280370",
              continue_button: "Continue",
            }
          end

          context "when the selected organisation has already been added to the current application" do
            before do
              create(:opponent, :for_organisation, legal_aid_application:, ccms_opponent_id: "280370")
            end

            it "renders index" do
              create_request
              expect(response).to have_http_status(:ok)
            end

            it "displays errors" do
              create_request
              expect(response.body).to include("govuk-input--error")
              expect(response.body).to include("govuk-form-group--error")
              expect(response.body).to have_content("You cannot select the same organisation twice. Choose a different one.")
            end
          end

          context "when LegalFramework::AddOpponentOrganisationService call returns true" do
            let(:service) { instance_double(LegalFramework::AddOpponentOrganisationService, call: true) }

            before do
              allow(LegalFramework::AddOpponentOrganisationService)
                .to receive(:new)
                .with(legal_aid_application)
                .and_return(service)
            end

            it "redirects to next step" do
              create_request
              expect(response).to have_http_status(:redirect)
            end

            it "calls the add opponent organisation service with expected object duck type" do
              create_request
              expect(service).to have_received(:call).with(duck_type(:name, :ccms_opponent_id, :ccms_type_code, :ccms_type_text))
            end
          end

          context "when LegalFramework::AddOpponentOrganisationService call returns false" do
            let(:service) { instance_double(LegalFramework::AddOpponentOrganisationService, call: false) }

            before do
              allow(LegalFramework::AddOpponentOrganisationService)
                .to receive(:new)
                .with(legal_aid_application)
                .and_return(service)
            end

            it "renders index" do
              create_request
              expect(response).to have_http_status(:ok)
            end

            it "displays errors" do
              create_request
              expect(response.body).to include("govuk-input--error")
              expect(response.body).to include("govuk-form-group--error")
            end
          end
        end

        context "with save as draft" do
          let(:params) { { draft_button: "Save as draft" } }

          it "redirects provider to provider's applications page" do
            create_request
            expect(response).to redirect_to(in_progress_providers_legal_aid_applications_path)
          end

          it "sets the application as draft" do
            expect { create_request }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
          end
        end
      end
    end
  end
end
