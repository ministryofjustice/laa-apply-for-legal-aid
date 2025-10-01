require "rails_helper"
require "sidekiq/testing"

RSpec.describe Providers::CheckMeritsAnswersController do
  include ActionView::Helpers::NumberHelper

  describe "GET /providers/applications/:id/check_merits_answers" do
    subject(:get_request) { get "/providers/applications/#{application.id}/check_merits_answers" }

    let(:application) do
      create(:legal_aid_application,
             :with_everything,
             :with_proceedings,
             :with_chances_of_success,
             :with_attempts_to_settle,
             :with_involved_children,
             :provider_entering_merits,
             domestic_abuse_summary:,
             matter_opposition:,
             explicit_proceedings: %i[da001 se014])
    end
    let(:smtl) { create(:legal_framework_merits_task_list, legal_aid_application: application) }
    let(:domestic_abuse_summary) { create(:domestic_abuse_summary, :police_notified_true) }
    let(:matter_opposition) { create(:matter_opposition) }
    let(:involved_child) { application.involved_children.first }

    before do
      allow(LegalFramework::MeritsTasksService).to receive(:call).with(application).and_return(smtl)
      application.proceedings.find_by(ccms_code: "SE014").involved_children << involved_child
      application.save!
    end

    context "when the provider is unauthenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when logged in as an authenticated provider" do
      before do
        login_as application.provider
        get_request
      end

      it "displays the correct page" do
        expect(unescaped_response_body).to include("Check your answers")
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays the correct questions" do
        scope = "govuk_component.summary_list_component.card_component"
        expect(response.body).to include(I18n.t("latest_incident_details.notification_of_latest_incident", scope:))
        expect(response.body).to include(I18n.t("latest_incident_details.date_of_latest_incident", scope:))
        expect(response.body).to include(I18n.t("parties_mental_capacity.understands_terms", scope:))
        expect(response.body).to include(I18n.t("domestic_abuse_summary.warning_letter_reasons", scope:))
        expect(response.body).to include(I18n.t("domestic_abuse_summary.police_notified_details", scope:))
        expect(response.body).to include(I18n.t("domestic_abuse_summary.bail_conditions", scope:))
        expect(response.body).to include(I18n.t("statement_of_case.statement_of_case", scope:))
        expect(response.body).to include(I18n.t("merits_proceeding_section.prospects_of_success", scope:))
        expect(response.body).to include(I18n.t("merits_proceeding_section.success_prospect", scope:))
      end

      it "displays the correct URLs for changing values" do
        expect(response.body).to have_link("Change", href: providers_legal_aid_application_date_client_told_incident_path)
        expect(response.body).to have_link("Change", href: providers_legal_aid_application_has_other_opponent_path(application))
        expect(response.body).to have_link("Change", href: providers_legal_aid_application_opponents_mental_capacity_path(application))
        expect(response.body).to have_link("Change", href: providers_legal_aid_application_domestic_abuse_summary_path(application))
        expect(response.body).to have_link("Change", href: providers_legal_aid_application_has_other_involved_children_path(application))
        expect(response.body).to have_link("Change", href: providers_legal_aid_application_matter_opposed_reason_path(application))
        expect(response.body).to have_link("Change", href: providers_legal_aid_application_in_scope_of_laspo_path(application))
        expect(response.body).to have_link("Change", href: providers_legal_aid_application_statement_of_case_path(application))
        expect(response.body).to have_link("Change", href: providers_merits_task_list_linked_children_path(application.proceedings.find_by(ccms_code: "SE014")))
        application.proceedings.each do |proceeding|
          expect(response.body).to have_change_link(:success_likely,
                                                    providers_merits_task_list_chances_of_success_path(proceeding))
        end
      end

      it "displays the question Date your client told you about the latest incident details" do
        expect(response.body).to include(I18n.t("govuk_component.summary_list_component.card_component.latest_incident_details.notification_of_latest_incident"))
        expect(response.body).to include(application.latest_incident.told_on.to_s)
      end

      it "displays the question Date of incident" do
        expect(response.body).to include(I18n.t("govuk_component.summary_list_component.card_component.latest_incident_details.date_of_latest_incident"))
        expect(response.body).to include(application.latest_incident.occurred_on.to_s)
      end

      it "displays the details of whether the opponent understands the terms of court order" do
        expect(response.body).to include(application.parties_mental_capacity.understands_terms_of_court_order_details)
      end

      it "displays the details of whether a warning letter has been sent" do
        expect(response.body).to include(application.domestic_abuse_summary.warning_letter_sent_details)
      end

      it "displays the details of whether the police has been notified" do
        expect(response.body).to include(application.domestic_abuse_summary.police_notified_details)
      end

      it "displays the details of whether the bail conditions have been set" do
        expect(response.body).to include(application.domestic_abuse_summary.bail_conditions_set_details)
      end

      it "displays the statement of case" do
        expect(response.body).to include(application.statement_of_case.statement)
      end

      it "displays linked children" do
        expect(response.body).to include(I18n.t("govuk_component.summary_list_component.card_component.merits_proceeding_section.linked_children"))
      end

      it "displays attempts to settle" do
        expect(response.body).to include(I18n.t("govuk_component.summary_list_component.card_component.merits_proceeding_section.attempts_to_settle"))
      end

      it 'changes the state to "checking_merits_answers"' do
        expect(application.reload).to be_checking_merits_answers
      end

      it "has a back link to the client declaration page" do
        expect(response.body).to have_back_link(reset_providers_legal_aid_application_check_merits_answers_path)
      end
    end
  end

  describe "PATCH /providers/applications/:id/check_merits_answers/continue" do
    subject(:patch_request) do
      patch "/providers/applications/#{application.id}/check_merits_answers/continue", params:
    end

    let(:application) do
      create(:legal_aid_application,
             :with_everything,
             :with_proceedings,
             :checking_merits_answers,
             explicit_proceedings: %i[da001 se014])
    end
    let(:params) { {} }
    let(:allow_ccms_submission) { true }
    let(:smtl) { create(:legal_framework_merits_task_list, legal_aid_application: application) }

    before { allow(LegalFramework::MeritsTasksService).to receive(:call).with(application).and_return(smtl) }

    context "when logged in as an authenticated provider" do
      before do
        login_as application.provider
      end

      context "when the continue button is pressed" do
        let(:submit_button) { { continue_button: "Continue" } }

        it "redirects to next page" do
          patch_request
          expect(response).to have_http_status(:redirect)
        end

        context "with a SCA application" do
          let(:application) { create(:legal_aid_application, :with_everything, :with_proceedings, explicit_proceedings: %i[pb003 pb059]) }
          let(:smtl) { create(:legal_framework_merits_task_list, :pb003_pb059, legal_aid_application: application) }
          let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[pb003 pb059]) }

          context "when the provider confirms the applicant requires separate representation" do
            let(:params) { { legal_aid_application: { separate_representation_required: "true" } } }

            it "redirects to next page" do
              patch_request
              expect(response).to have_http_status(:redirect)
            end

            it "updates separate_representation required" do
              patch_request
              expect(application.reload.separate_representation_required).to be true
            end
          end

          context "when the provider does not confirm that the applicant requires separate representation" do
            let(:params) { { legal_aid_application: { separate_representation_required: "" } } }

            it "doesn't update the application and displays an error" do
              patch_request
              expect(application.reload.separate_representation_required).to be_nil
              expect(page).to have_error_message("Confirm your client wants separate representation")
            end
          end
        end
      end
    end

    context "when the provider is unauthenticated" do
      before { patch_request }

      it_behaves_like "a provider not authenticated"
    end
  end

  describe 'PATCH "/providers/applications/:id/check_merits_answers/reset' do
    subject(:patch_request) { patch "/providers/applications/#{application.id}/check_merits_answers/reset" }

    let(:application) do
      create(:legal_aid_application,
             :with_everything,
             :with_proceedings,
             :checking_merits_answers,
             explicit_proceedings: %i[da001])
    end
    let(:da001) { application.proceedings.find_by(ccms_code: "DA001") }
    let(:smtl) { create(:legal_framework_merits_task_list, :da001, legal_aid_application: application) }

    before { create(:chances_of_success, :with_optional_text, proceeding: da001) }

    context "when the provider is unauthenticated" do
      before { patch_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when logged in as an authenticated provider" do
      before do
        allow(LegalFramework::MeritsTasksService).to receive(:call).with(application).and_return(smtl)
        login_as application.provider
        get providers_legal_aid_application_end_of_application_path(application)
        get providers_legal_aid_application_check_merits_answers_path(application)
      end

      it "transitions to provider_entering_merits state" do
        patch_request
        expect(application.reload.provider_entering_merits?).to be true
      end

      context "when no required document categories" do
        it "redirects to merits task page" do
          patch_request
          expect(response).to redirect_to providers_legal_aid_application_merits_task_list_path(application)
        end
      end

      context "when there are required document categories" do
        before do
          allow(LegalFramework::MeritsTasksService).to receive(:call).with(application).and_return(smtl)
          allow(LegalAidApplication).to receive(:find).and_return(application)
          allow(application).to receive(:evidence_is_required?).and_return(true)
        end

        it "redirects to upload evidence page" do
          patch_request
          expect(response).to redirect_to providers_legal_aid_application_uploaded_evidence_collection_path(application)
        end
      end
    end
  end
end
