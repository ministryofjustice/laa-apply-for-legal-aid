require "rails_helper"
require "sidekiq/testing"

RSpec.describe "check merits answers requests" do
  include ActionView::Helpers::NumberHelper

  describe "GET /providers/applications/:id/check_merits_answers" do
    subject { get "/providers/applications/#{application.id}/check_merits_answers" }

    let(:application) do
      create(:legal_aid_application,
             :with_everything,
             :with_proceedings,
             :with_chances_of_success,
             :with_attempts_to_settle,
             :with_involved_children,
             :provider_entering_merits,
             explicit_proceedings: %i[da001 se014])
    end
    let(:smtl) { create(:legal_framework_merits_task_list, legal_aid_application: application) }

    before { allow(LegalFramework::MeritsTasksService).to receive(:call).with(application).and_return(smtl) }

    context "unauthenticated" do
      before { subject }

      it_behaves_like "a provider not authenticated"
    end

    context "logged in as an authenticated provider" do
      before do
        login_as application.provider
        subject
      end

      it "displays the correct page" do
        expect(unescaped_response_body).to include("Check your answers")
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays the correct questions" do
        scope = "shared.check_answers.merits.items"
        expect(response.body).to include(I18n.t("notification_of_latest_incident", scope:))
        expect(response.body).to include(I18n.t("date_of_latest_incident", scope:))
        expect(response.body).to include(I18n.t("understands_terms_of_court_order", scope:))
        expect(response.body).to include(I18n.t("warning_letter_sent", scope:))
        expect(response.body).to include(I18n.t("police_notified", scope:))
        expect(response.body).to include(I18n.t("bail_conditions_set", scope:))
        expect(response.body).to include(I18n.t("statement_of_case", scope:))
        expect(response.body).to include(I18n.t("prospects_of_success", scope:))
        expect(response.body).to include(I18n.t("success_prospect", scope:))
      end

      it "displays the correct URLs for changing values" do
        expect(response.body).to have_change_link(:incident_details, providers_legal_aid_application_date_client_told_incident_path)
        expect(response.body).to have_change_link(:full_name, providers_legal_aid_application_opponents_name_path(application))
        expect(response.body).to have_change_link(:statement_of_case, providers_legal_aid_application_statement_of_case_path(application))
        application.proceedings.each do |proceeding|
          expect(response.body).to have_change_link(:success_likely,
                                                    providers_merits_task_list_chances_of_success_index_path(proceeding))
        end
      end

      it "displays the question When did your client tell you about the latest domestic abuse incident" do
        expect(response.body).to include(I18n.t("shared.forms.date_input_fields.told_on_label"))
        expect(response.body).to include(application.latest_incident.told_on.to_s)
      end

      it "displays the question When did the incident occur?" do
        expect(response.body).to include(I18n.t("shared.forms.date_input_fields.occurred_on_label"))
        expect(response.body).to include(application.latest_incident.occurred_on.to_s)
      end

      it "displays the details of whether the opponent understands the terms of court order" do
        expect(response.body).to include(application.opponent.understands_terms_of_court_order_details)
      end

      it "displays the details of whether a warning letter has been sent" do
        expect(response.body).to include(application.opponent.warning_letter_sent_details)
      end

      it "displays the details of whether the police has been notified" do
        expect(response.body).to include(application.opponent.police_notified_details)
      end

      it "displays the details of whether the bail conditions have been set" do
        expect(response.body).to include(application.opponent.bail_conditions_set_details)
      end

      it "displays the statement of case" do
        expect(response.body).to include(application.statement_of_case.statement)
      end

      it "displays the warning text When did the incident occur?" do
        expect(response.body).to include(I18n.t("shared.forms.date_input_fields.occurred_on_label"))
        expect(response.body).to include(application.latest_incident.occurred_on.to_s)
      end

      it "displays linked children" do
        expect(response.body).to include(I18n.t("shared.check_answers.merits.items.linked_children"))
      end

      it "displays attempts to settle" do
        expect(response.body).to include(I18n.t("shared.check_answers.merits.items.attempts_to_settle"))
      end

      it 'changes the state to "checking_merits_answers"' do
        expect(application.reload.checking_merits_answers?).to be_truthy
      end

      it "has a back link to the client declaration page" do
        expect(response.body).to have_back_link(reset_providers_legal_aid_application_check_merits_answers_path)
      end
    end
  end

  describe "PATCH /providers/applications/:id/check_merits_answers/continue" do
    subject do
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

    context "logged in as an authenticated provider" do
      before do
        login_as application.provider
      end

      context "Continue button pressed" do
        let(:submit_button) { { continue_button: "Continue" } }

        it "redirects to next page" do
          subject
          expect(response).to redirect_to(providers_legal_aid_application_confirm_client_declaration_path(application))
        end
      end
    end

    context "unauthenticated" do
      before { subject }

      it_behaves_like "a provider not authenticated"
    end
  end

  describe 'PATCH "/providers/applications/:id/check_merits_answers/reset' do
    subject { patch "/providers/applications/#{application.id}/check_merits_answers/reset" }

    let(:application) do
      create(:legal_aid_application,
             :with_everything,
             :with_proceedings,
             :checking_merits_answers,
             explicit_proceedings: %i[da001])
    end
    let(:da001) { application.proceedings.find_by(ccms_code: "DA001") }
    let(:smtl) { create(:legal_framework_merits_task_list, :da001, legal_aid_application: application) }
    let!(:chances_of_success) do
      create(:chances_of_success, :with_optional_text, proceeding: da001)
    end

    context "unauthenticated" do
      before { subject }

      it_behaves_like "a provider not authenticated"
    end

    context "logged in as an authenticated provider" do
      before do
        allow(LegalFramework::MeritsTasksService).to receive(:call).with(application).and_return(smtl)
        login_as application.provider
        get providers_legal_aid_application_end_of_application_path(application)
        get providers_legal_aid_application_check_merits_answers_path(application)
      end

      it "transitions to provider_entering_merits state" do
        subject
        expect(application.reload.provider_entering_merits?).to be true
      end

      context "when no required document categories" do
        it "redirects to merits task page" do
          subject
          expect(response).to redirect_to providers_legal_aid_application_merits_task_list_path(application)
        end
      end

      context "when there are required document categories" do
        before do
          allow(LegalFramework::MeritsTasksService).to receive(:call).with(application).and_return(smtl)
          allow(LegalAidApplication).to receive(:find_by).and_return(application)
          allow(application).to receive(:evidence_is_required?).and_return(true)
        end

        it "redirects to upload evidence page" do
          subject
          expect(response).to redirect_to providers_legal_aid_application_uploaded_evidence_collection_path(application)
        end
      end
    end
  end
end
