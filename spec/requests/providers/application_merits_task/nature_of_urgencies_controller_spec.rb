require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe NatureOfUrgenciesController do
      let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8) }
      let(:login_provider) { login_as legal_aid_application.provider }
      let(:smtl) { create(:legal_framework_merits_task_list, :da001_and_child_section_8_with_delegated_functions, legal_aid_application:) }

      describe "GET /providers/applications/:legal_aid_application_id/nature_of_urgencies" do
        subject(:nature_of_urgencies) { get providers_legal_aid_application_nature_of_urgencies_path(legal_aid_application) }

        before do
          login_provider
          nature_of_urgencies
        end

        it "renders successfully" do
          expect(response).to have_http_status(:ok)
        end

        context "when not authenticated" do
          let(:login_provider) { nil }

          it_behaves_like "a provider not authenticated"
        end
      end

      describe "PATCH /providers/applications/:legal_aid_application_id/nature_of_urgencies" do
        subject(:post_nature_of_urgencies) do
          patch(
            providers_legal_aid_application_nature_of_urgencies_path(legal_aid_application),
            params: params.merge(button_clicked),
          )
        end

        let(:nature_of_urgency) { "This is the nature of the urgency" }
        let(:hearing_date_set) { false }
        let(:hearing_date_1i) { Date.yesterday.year }
        let(:hearing_date_2i) { Date.yesterday.month }
        let(:hearing_date_3i) { Date.yesterday.day }
        let(:params) do
          {
            application_merits_task_urgency: {
              nature_of_urgency:,
              hearing_date_set:,
              "hearing_date(1i)": hearing_date_1i,
              "hearing_date(2i)": hearing_date_2i,
              "hearing_date(3i)": hearing_date_3i,
            },
          }
        end
        let(:draft_button) { { draft_button: "Save as draft" } }
        let(:button_clicked) { {} }
        let(:urgency) { legal_aid_application.reload.urgency }

        before do
          allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
          login_provider
        end

        context "when hearing_date_set is false" do
          it "creates a new urgency with the values entered without a hearing date" do
            expect { post_nature_of_urgencies }.to change(::ApplicationMeritsTask::Urgency, :count).by(1)
            expect(urgency.nature_of_urgency).to eq "This is the nature of the urgency"
            expect(urgency.hearing_date_set).to be_falsey
            expect(urgency.hearing_date).to be_nil
          end

          it "redirects to the next page" do
            post_nature_of_urgencies
            expect(response).to redirect_to(flow_forward_path)
          end
        end

        context "when hearing_date_set is true" do
          let(:hearing_date_set) { true }

          it "creates a new urgency with the values entered without a hearing date" do
            expect { post_nature_of_urgencies }.to change(::ApplicationMeritsTask::Urgency, :count).by(1)
            expect(urgency.nature_of_urgency).to eq "This is the nature of the urgency"
            expect(urgency.hearing_date_set).to be true
            expect(urgency.hearing_date).to eq Date.yesterday
          end

          it "redirects to the next page" do
            post_nature_of_urgencies
            expect(response).to redirect_to(flow_forward_path)
          end
        end

        context "when not authenticated" do
          let(:login_provider) { nil }

          before { post_nature_of_urgencies }

          it_behaves_like "a provider not authenticated"
        end

        context "when save as draft selected" do
          let(:button_clicked) { draft_button }

          it "redirects to provider draft endpoint" do
            post_nature_of_urgencies
            expect(response).to redirect_to provider_draft_endpoint
          end

          it "does not set the task to complete" do
            post_nature_of_urgencies
            expect(legal_aid_application.legal_framework_merits_task_list).to have_not_started_task(:application, :nature_of_urgency)
          end
        end
      end
    end
  end
end
