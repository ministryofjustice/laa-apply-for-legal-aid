require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe OpponentsController do
      let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8) }
      let(:login_provider) { login_as legal_aid_application.provider }
      let(:smtl) { create(:legal_framework_merits_task_list, legal_aid_application:) }
      let(:proceeding) { laa.proceedings.detect { |p| p.ccms_code == "SE014" } }

      describe "GET /providers/applications/:legal_aid_application_id/opponent" do
        subject { get providers_legal_aid_application_opponent_path(legal_aid_application) }

        before do
          allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
          login_provider
          subject
        end

        it "renders successfully" do
          expect(response).to have_http_status(:ok)
        end

        context "when not authenticated" do
          let(:login_provider) { nil }

          it_behaves_like "a provider not authenticated"
        end

        context "with an existing opponent" do
          let(:opponent) { create(:opponent) }
          let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[da001 se014], opponent:) }

          it "renders successfully" do
            expect(response).to have_http_status(:ok)
          end

          it "displays opponent data" do
            expect(response.body).to include(html_compare(opponent.full_name))
            expect(response.body).to include(opponent.understands_terms_of_court_order_details)
            expect(response.body).to include(opponent.warning_letter_sent_details)
            expect(response.body).to include(opponent.police_notified_details)
            expect(response.body).to include(opponent.bail_conditions_set_details)
          end
        end
      end

      describe "PATCH /providers/applications/:legal_aid_application_id/opponent" do
        subject do
          patch(
            providers_legal_aid_application_opponent_path(legal_aid_application),
            params: params.merge(button_clicked),
          )
        end

        let(:sample_opponent) { build(:opponent, :police_notified_true) }
        let(:full_name) { Faker::Name.name }
        let(:params) do
          {
            application_merits_task_opponent: {
              full_name:,
              understands_terms_of_court_order: sample_opponent.understands_terms_of_court_order.to_s,
              understands_terms_of_court_order_details: sample_opponent.understands_terms_of_court_order_details,
              warning_letter_sent: sample_opponent.warning_letter_sent.to_s,
              warning_letter_sent_details: sample_opponent.warning_letter_sent_details,
              police_notified: sample_opponent.police_notified.to_s,
              police_notified_details_true: sample_opponent.police_notified_details,
              bail_conditions_set: sample_opponent.bail_conditions_set.to_s,
              bail_conditions_set_details: sample_opponent.bail_conditions_set_details,
            },
          }
        end
        let(:draft_button) { { draft_button: "Save as draft" } }
        let(:button_clicked) { {} }
        let(:opponent) { legal_aid_application.reload.opponent }

        before do
          allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
          login_provider
        end

        it "creates a new opponent with the values entered" do
          expect { subject }.to change(::ApplicationMeritsTask::Opponent, :count).by(1)
          expect(opponent.understands_terms_of_court_order).to eq(sample_opponent.understands_terms_of_court_order)
          expect(opponent.understands_terms_of_court_order_details).to eq(sample_opponent.understands_terms_of_court_order_details)
          expect(opponent.warning_letter_sent).to eq(sample_opponent.warning_letter_sent)
          expect(opponent.warning_letter_sent_details).to eq(sample_opponent.warning_letter_sent_details)
          expect(opponent.police_notified).to eq(sample_opponent.police_notified)
          expect(opponent.police_notified_details).to eq(sample_opponent.police_notified_details)
          expect(opponent.bail_conditions_set).to eq(sample_opponent.bail_conditions_set)
          expect(opponent.bail_conditions_set_details).to eq(sample_opponent.bail_conditions_set_details)
        end

        it "sets the task to complete" do
          subject
          expect(legal_aid_application.legal_framework_merits_task_list).to have_completed_task(:application, :opponent_details)
        end

        context "when no other tasks are complete" do
          it "redirects to the next incomplete question" do
            subject
            expect(response).to redirect_to(providers_legal_aid_application_date_client_told_incident_path(legal_aid_application))
          end
        end

        context "when the first task is complete" do
          before { legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :latest_incident_details) }

          it "redirects to the next incomplete question" do
            subject
            expect(response).to redirect_to(new_providers_legal_aid_application_involved_child_path(legal_aid_application))
          end
        end

        context "when the all but one task is complete" do
          before do
            legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :latest_incident_details)
            legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :children_application)
          end

          it "redirects to the final question" do
            subject
            expect(response).to redirect_to(providers_legal_aid_application_statement_of_case_path(legal_aid_application))
          end
        end

        context "when attributes have trailing whitespaces" do
          let(:full_name) { "   John   Doe  " }
          let(:sample_opponent) { build(:opponent, :police_notified_true, warning_letter_sent_details: "  extra    space  ") }

          context "with fullname" do
            it "removes excess whitespaces" do
              subject
              expect(opponent.reload.full_name).to eq "John Doe"
            end
          end

          context "when not a fullname attribute" do
            it "leaves the excess whitespaces" do
              subject
              expect(opponent.reload.warning_letter_sent_details).to eq "  extra    space  "
            end
          end
        end

        context "when not authenticated" do
          let(:login_provider) { nil }

          before { subject }

          it_behaves_like "a provider not authenticated"
        end

        context "when incomplete" do
          let(:sample_opponent) { ::ApplicationMeritsTask::Opponent.new }

          it "renders show" do
            subject
            expect(response).to have_http_status(:ok)
          end

          it "does not set the task to complete" do
            subject
            expect(legal_aid_application.legal_framework_merits_task_list).to have_not_started_task(:application, :opponent_details)
          end
        end

        context "when save as draft selected" do
          let(:button_clicked) { draft_button }

          it "redirects to provider draft endpoint" do
            subject
            expect(response).to redirect_to providers_legal_aid_applications_path
          end

          it "does not set the task to complete" do
            subject
            expect(legal_aid_application.legal_framework_merits_task_list).to have_not_started_task(:application, :opponent_details)
          end
        end
      end
    end
  end
end
