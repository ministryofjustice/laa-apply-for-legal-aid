require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe ClientOfferedUndertakingsController do
      let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8) }
      let(:login_provider) { login_as legal_aid_application.provider }
      let(:smtl) { create(:legal_framework_merits_task_list, :da001_as_defendant, legal_aid_application:) }

      describe "GET /providers/applications/:legal_aid_application_id/client_offered_undertakings" do
        subject(:client_undertakings) { get providers_legal_aid_application_client_offered_undertakings_path(legal_aid_application) }

        before do
          login_provider
          client_undertakings
        end

        it "renders successfully" do
          expect(response).to have_http_status(:ok)
        end

        context "when not authenticated" do
          let(:login_provider) { nil }

          it_behaves_like "a provider not authenticated"
        end

        context "with an existing undertaking" do
          let(:undertaking) { create(:undertaking, :with_data) }
          let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8, undertaking:) }

          it "renders successfully" do
            expect(response).to have_http_status(:ok)
          end

          it "displays additional information" do
            expect(response.body).to include("extenuating circumstances")
          end
        end
      end

      describe "PATCH /providers/applications/:legal_aid_application_id/client_offered_undertakings" do
        subject(:post_client_undertakings) do
          patch(
            providers_legal_aid_application_client_offered_undertakings_path(legal_aid_application),
            params: params.merge(button_clicked),
          )
        end

        let(:offered) { "true" }
        let(:additional_information_true) { "yes answer" }
        let(:additional_information_false) { "" }
        let(:params) do
          {
            application_merits_task_undertaking: {
              offered:,
              additional_information_true:,
              additional_information_false:,
            },
          }
        end
        let(:draft_button) { { draft_button: "Save as draft" } }
        let(:button_clicked) { {} }
        let(:undertaking) { legal_aid_application.reload.undertaking }

        before do
          allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
          login_provider
        end

        it "creates a new undertaking with the values entered" do
          expect { post_client_undertakings }.to change(::ApplicationMeritsTask::Undertaking, :count).by(1)
          expect(undertaking.offered).to be_truthy
          expect(undertaking.additional_information).to eq "yes answer"
        end

        it "sets the task to complete" do
          post_client_undertakings
          expect(legal_aid_application.legal_framework_merits_task_list).to have_completed_task(:application, :client_offer_of_undertakings)
        end

        it "redirects to the next page" do
          post_client_undertakings
          expect(response).to have_http_status(:redirect)
        end

        context "when not authenticated" do
          let(:login_provider) { nil }

          before { post_client_undertakings }

          it_behaves_like "a provider not authenticated"
        end

        context "when incomplete" do
          let(:offered) { "false" }
          let(:additional_information_true) { "" }
          let(:additional_information_false) { "" }

          it "renders show" do
            post_client_undertakings
            expect(response).to have_http_status(:ok)
          end

          it "does not set the task to complete" do
            post_client_undertakings
            expect(legal_aid_application.legal_framework_merits_task_list).to have_not_started_task(:application, :client_offer_of_undertakings)
          end
        end

        context "when save as draft selected" do
          let(:button_clicked) { draft_button }

          it "redirects to provider draft endpoint" do
            post_client_undertakings
            expect(response).to redirect_to provider_draft_endpoint
          end

          it "does not set the task to complete" do
            post_client_undertakings
            expect(legal_aid_application.legal_framework_merits_task_list).to have_not_started_task(:application, :client_offer_of_undertakings)
          end
        end
      end
    end
  end
end
