require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe ClientOfferedUndertakingsController, type: :request do
      let(:legal_aid_application) { create :legal_aid_application, :with_multiple_proceedings_inc_section8 }
      let(:login_provider) { login_as legal_aid_application.provider }
      let(:smtl) { create :legal_framework_merits_task_list, :da001_as_defendant, legal_aid_application: }

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
          let(:undertaking) { create :undertaking, :with_data }
          let(:legal_aid_application) { create :legal_aid_application, :with_multiple_proceedings_inc_section8, undertaking: }

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

        let(:offered) { true }
        let(:additional_information) { "" }
        let(:params) do
          {
            application_merits_task_undertaking: {
              offered:,
              additional_information:,
            },
          }
        end
        let(:draft_button) { { draft_button: "Save as draft" } }
        let(:button_clicked) { {} }
        let(:undertaking) { legal_aid_application.reload.undertaking }
        let(:not_started_regex) { /name: :client_offer_of_undertakings\n\s+dependencies: \*\d\n\s+state: :not_started/ }

        before do
          allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
          login_provider
        end

        it "creates a new undertaking with the values entered" do
          expect { post_client_undertakings }.to change(::ApplicationMeritsTask::Undertaking, :count).by(1)
          expect(undertaking.offered).to be_truthy
          expect(undertaking.additional_information).to eq ""
        end

        it "sets the task to complete" do
          post_client_undertakings
          expect(legal_aid_application.legal_framework_merits_task_list.serialized_data).to match(/name: :client_offer_of_undertakings\n\s+dependencies: \*\d\n\s+state: :complete/)
        end

        it "redirects to the next page" do
          post_client_undertakings
          expect(response).to redirect_to(flow_forward_path)
        end

        context "when not authenticated" do
          let(:login_provider) { nil }

          before { post_client_undertakings }

          it_behaves_like "a provider not authenticated"
        end

        context "when incomplete" do
          let(:offered) { false }
          let(:additional_information) { "" }

          it "renders show" do
            post_client_undertakings
            expect(response).to have_http_status(:ok)
          end

          it "does not set the task to complete" do
            post_client_undertakings
            expect(legal_aid_application.legal_framework_merits_task_list.serialized_data).to match(not_started_regex)
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
            expect(legal_aid_application.legal_framework_merits_task_list.serialized_data).to match(not_started_regex)
          end
        end
      end
    end
  end
end
