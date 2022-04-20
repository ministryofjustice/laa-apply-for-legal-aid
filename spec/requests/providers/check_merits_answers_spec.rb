require "rails_helper"
require "sidekiq/testing"

RSpec.describe "check merits answers requests", type: :request do
  include ActionView::Helpers::NumberHelper

  describe "GET /providers/applications/:id/check_merits_answers" do
    subject { get "/providers/applications/#{application.id}/check_merits_answers" }

    let(:application) do
      create :legal_aid_application,
             :with_everything,
             :with_proceedings,
             :with_chances_of_success,
             :with_attempts_to_settle,
             :with_involved_children,
             :provider_entering_merits,
             proceeding_count: 3
    end

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
        expect(response.body).to have_change_link(:opponent_details, providers_legal_aid_application_opponent_path)
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

      it "displays the warning text" do
        expect(response.body).to include(I18n.t("providers.check_merits_answers.show.sign_app_text"))
        expect(unescaped_response_body).to include(application.provider.firm.name)
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
      patch "/providers/applications/#{application.id}/check_merits_answers/continue", params: params
    end

    let(:application) do
      create :legal_aid_application,
             :with_everything,
             :with_proceedings,
             :checking_merits_answers
    end
    let(:params) { {} }
    before { allow(EnableCCMSSubmission).to receive(:call).and_return(allow_ccms_submission) }

    let(:allow_ccms_submission) { true }

    context "logged in as an authenticated provider" do
      before do
        login_as application.provider
      end

      context "Continue button pressed" do
        let(:submit_button) { { continue_button: "Continue" } }

        it "updates the record" do
          expect { subject }.to change { application.reload.merits_submitted_at }.from(nil)
          expect(application.reload).to be_generating_reports
        end
      end

      it "redirects to next page" do
        subject
        expect(response).to redirect_to(providers_legal_aid_application_end_of_application_path(application))
      end

      it "creates pdf reports" do
        ReportsCreatorWorker.clear
        expect(Reports::ReportsCreator).to receive(:call).with(application)
        subject
        ReportsCreatorWorker.drain
      end

      it "sets the merits assessment to submitted" do
        subject
        expect(application.reload.summary_state).to eq :submitted
      end

      context "when the Setting.enable_ccms_submission?" do
        context "is turned on" do
          it "transitions to generating_reports state" do
            subject
            expect(application.reload).to be_generating_reports
            # expect(application.reload.state).to eq 'generating_reports'
          end
        end

        context "is turned off" do
          let(:allow_ccms_submission) { false }

          it "transitions to submission_paused state" do
            subject
            expect(application.reload.state).to eq "submission_paused"
          end
        end
      end

      context "Form submitted using Save as draft button" do
        let(:params) { { draft_button: "Save as draft" } }

        it "redirect provider to provider's applications page" do
          subject
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it "sets the application as draft" do
          subject
          expect(application.reload).to be_draft
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
      create :legal_aid_application,
             :with_everything,
             :with_proceedings,
             :checking_merits_answers,
             explicit_proceedings: %i[da004]
    end
    let(:da004) { application.proceedings.find_by(ccms_code: "DA004") }

    let!(:chances_of_success) do
      create :chances_of_success, :with_optional_text, proceeding: da004
    end

    context "unauthenticated" do
      before { subject }

      it_behaves_like "a provider not authenticated"
    end

    context "logged in as an authenticated provider" do
      before do
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
