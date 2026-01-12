require "rails_helper"

RSpec.describe Providers::MeritsTaskListsController do
  let(:login_provider) { login_as legal_aid_application.provider }
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_multiple_proceedings_inc_section8) }
  let(:evidence_upload) { false }

  let(:proceeding_names) do
    legal_aid_application.proceedings.map(&:meaning)
  end
  let(:task_list) { create(:legal_framework_merits_task_list, legal_aid_application:) }

  before do
    legal_aid_application
    allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(task_list)
    login_provider
  end

  describe "GET /providers/merits_task_list" do
    subject(:get_request) { get providers_legal_aid_application_merits_task_list_path(legal_aid_application) }

    before { get providers_legal_aid_application_merits_task_list_path(legal_aid_application) }

    context "when the record does not exist" do
      let(:task_list) { build(:legal_framework_serializable_merits_task_list) }

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays a section for the whole application" do
        expect(response.body).to include("About the application")
      end

      it "displays a section for all proceeding types linked to this application" do
        proceeding_names.each { |name| expect(response.body).to include("About the #{name}") }
      end
    end

    context "when the record already exists" do
      before do
        login_provider
        create(:legal_framework_merits_task_list, legal_aid_application:)
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays a section for the whole application" do
        expect(response.body).to include("About the application")
      end

      it "displays a section for all proceeding types linked to this application" do
        proceeding_names.each { |name| expect(response.body).to include("About the #{name}") }
      end
    end

    context "when the task list was started before the opponent split was implemented" do
      let(:task_list) { create(:legal_framework_merits_task_list, :broken_opponent, legal_aid_application:) }

      it "calls the OpponentTaskUpdateService and replaces the opponent_details task and returns http success" do
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Opponents")
        expect(response.body).to include("Mental capacity of all parties")
        expect(response.body).to include("Domestic abuse summary")
      end
    end

    describe ".back_button" do
      it "does displays a back link" do
        get_request
        expect(response.body).to have_css("a", class: "govuk-back-link")
      end

      context "when the provider has navigated from the providers_legal_aid_application_confirm_non_means_tested_applications_path" do
        let(:legal_aid_application) do
          create(
            :legal_aid_application,
            :with_applicant,
            :with_proceedings,
            :at_applicant_details_checked,
            explicit_proceedings: %i[pb003 pb059],
          )
        end
        let(:task_list) { create(:legal_framework_merits_task_list, :pb003_pb059_application, legal_aid_application:) }

        before { get providers_legal_aid_application_confirm_non_means_tested_applications_path(legal_aid_application) }

        it "does not show a back link" do
          get_request
          expect(response.body).to have_no_css("a", class: "govuk-back-link")
        end
      end
    end
  end

  describe "PATCH /providers/merits_task_list" do
    context "when all tasks are complete" do
      before do
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :latest_incident_details)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :opponent_name)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :opponent_mental_capacity)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :domestic_abuse_summary)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :children_application)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :why_matter_opposed)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :statement_of_case)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :laspo)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:DA001, :chances_of_success)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:SE014, :chances_of_success)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:SE014, :children_proceeding)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:SE014, :attempts_to_settle)
        DocumentCategory.populate
        patch providers_legal_aid_application_merits_task_list_path(legal_aid_application)
      end

      describe "evidence upload" do
        context "and at least one evidence type is required" do
          it "redirects to the next page" do
            expect(response).to have_http_status(:redirect)
          end
        end
      end
    end

    context "when no documents required" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_proceedings, explicit_proceedings: [:da001]) }
      let(:task_list) { create(:legal_framework_merits_task_list, :da001, legal_aid_application:) }

      before do
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :latest_incident_details)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :opponent_name)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :opponent_mental_capacity)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :domestic_abuse_summary)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :statement_of_case)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:DA001, :chances_of_success)
        patch providers_legal_aid_application_merits_task_list_path(legal_aid_application)
      end

      it "redirects to the next page" do
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when some tasks are incomplete" do
      before { patch providers_legal_aid_application_merits_task_list_path(legal_aid_application) }

      it { expect(response).to have_http_status(:ok) }
      it { expect(response.body).to include("Provide details of the case") }
      it { expect(response.body).to include("There is a problem") }
    end
  end
end
