require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe OpponentIndividualsController do
      let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8) }
      let(:login_provider) { login_as legal_aid_application.provider }
      let(:smtl) { create(:legal_framework_merits_task_list, legal_aid_application:) }
      let(:proceeding) { laa.proceedings.detect { |p| p.ccms_code == "SE014" } }

      describe "new: GET /providers/applications/:legal_aid_application_id/opponent_individuals/new" do
        subject(:get_new_opponent) { get new_providers_legal_aid_application_opponent_individual_path(legal_aid_application) }

        context "when authenticated" do
          before do
            login_provider
            get_new_opponent
          end

          it "returns success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the form to add new children" do
            expect(response.body).to include(html_compare("Opponent"))
            expect(response.body).to include("First name")
            expect(response.body).to include("Last name")
          end
        end

        context "when unauthenticated" do
          before { get_new_opponent }

          it_behaves_like "a provider not authenticated"
        end
      end

      describe "show: GET /providers/applications/:legal_aid_application_id/opponent_individuals/:opponent_id" do
        subject(:get_existing_opponent) { get providers_legal_aid_application_opponent_individual_path(legal_aid_application, opponent) }

        let(:opponent) { create(:opponent, :for_individual, legal_aid_application:) }

        context "when authenticated" do
          before do
            login_provider
            get_existing_opponent
          end

          it "returns success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays opponent's name" do
            expect(response.body)
              .to include(html_compare(opponent.first_name))
              .and include(html_compare(opponent.last_name))
          end
        end

        context "when unauthenticated" do
          before { get_existing_opponent }

          it_behaves_like "a provider not authenticated"
        end
      end

      describe "update: PATCH /providers/applications/:legal_aid_application_id/opponent_individuals/:opponent_id" do
        subject(:patch_name) do
          patch(
            providers_legal_aid_application_opponent_individual_path(legal_aid_application, opponent),
            params: params.merge(button_clicked),
          )
        end

        let!(:opponent) { create(:opponent, legal_aid_application:, first_name: "Milly", last_name: "Bobs") }

        let(:params) do
          {
            application_merits_task_opponent: {
              first_name: "Billy",
              last_name: "Bob",
            },
          }
        end

        let(:draft_button) { { draft_button: "Save as draft" } }
        let(:button_clicked) { {} }

        before do
          allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
          create(:opponent, legal_aid_application:, first_name: "Does", last_name: "Not-Change")
          login_provider
        end

        it "amends the opponent with the values entered" do
          expect { patch_name }.not_to change(::ApplicationMeritsTask::Opponent, :count)
          expect(opponent.reload.full_name).to eql "Billy Bob"
        end

        it "amends the opponent opposable individual with the values entered" do
          expect { patch_name }.not_to change(::ApplicationMeritsTask::Individual, :count)
          expect(opponent.opposable.reload.full_name).to eql "Billy Bob"
        end

        it "sets the task to complete" do
          patch_name
          expect(legal_aid_application.legal_framework_merits_task_list.serialized_data).to match(/name: :opponent_name\n\s+dependencies: \*\d+\n\s+state: :complete/)
        end

        it "redirects to the next step" do
          patch_name
          expect(response).to have_http_status(:redirect)
        end

        context "when not authenticated" do
          let(:login_provider) { nil }

          before { patch_name }

          it_behaves_like "a provider not authenticated"
        end

        context "when incomplete" do
          let(:params) do
            {
              application_merits_task_opponent: {
                last_name: "",
              },
            }
          end

          it "renders show" do
            patch_name
            expect(response).to have_http_status(:ok)
          end

          it "does not set the task to complete" do
            patch_name
            expect(legal_aid_application.legal_framework_merits_task_list.serialized_data).to match(/name: :opponent_name\n\s+dependencies: \*\d+\n\s+state: :not_started/)
          end
        end

        context "when save as draft selected" do
          let(:button_clicked) { draft_button }

          it "redirects to provider draft endpoint" do
            patch_name
            expect(response).to redirect_to in_progress_providers_legal_aid_applications_path
          end

          it "does not set the task to complete" do
            patch_name
            expect(legal_aid_application.legal_framework_merits_task_list.serialized_data).to match(/name: :opponent_name\n\s+dependencies: \*\d+\n\s+state: :not_started/)
          end
        end
      end
    end
  end
end
