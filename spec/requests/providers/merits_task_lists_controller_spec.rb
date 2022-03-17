require "rails_helper"

RSpec.describe Providers::MeritsTaskListsController, type: :request do
  let(:login_provider) { login_as legal_aid_application.provider }
  let(:legal_aid_application) { create :legal_aid_application, :with_multiple_proceedings_inc_section8 }
  let(:evidence_upload) { false }

  let(:proceeding_names) do
    legal_aid_application.proceedings.map(&:meaning)
  end
  let(:task_list) { create :legal_framework_merits_task_list, legal_aid_application: legal_aid_application }

  before do
    Setting.setting.update!(enable_evidence_upload: evidence_upload)
    legal_aid_application
    allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(task_list)
    login_provider
    subject
  end

  describe "GET /providers/merits_task_list" do
    subject { get providers_legal_aid_application_merits_task_list_path(legal_aid_application) }
    context "the record does not exist" do
      let(:task_list) { build :legal_framework_serializable_merits_task_list }

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays a section for the whole application" do
        expect(response.body).to include("Case details")
      end

      it "displays a section for all proceeding types linked to this application" do
        proceeding_names.each { |name| expect(response.body).to include(name) }
      end
    end

    context "the record already exists" do
      before do
        login_provider
        create :legal_framework_merits_task_list, legal_aid_application: legal_aid_application
        subject
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays a section for the whole application" do
        expect(response.body).to include("Case details")
      end

      it "displays a section for all proceeding types linked to this application" do
        subject
        proceeding_names.each { |name| expect(response.body).to include(name) }
      end
    end
  end

  describe "PATCH /providers/merits_task_list" do
    context "when all tasks are complete" do
      before do
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :latest_incident_details)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :opponent_details)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :children_application)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :statement_of_case)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:DA001, :chances_of_success)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:SE014, :chances_of_success)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:SE014, :children_proceeding)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:SE014, :attempts_to_settle)
        DocumentCategory.populate
        patch providers_legal_aid_application_merits_task_list_path(legal_aid_application)
      end

      context "when evidence upload setting  is off" do
        let(:evidence_upload) { false }

        it "redirects to the gateway evidence page" do
          expect(response).to redirect_to(providers_legal_aid_application_gateway_evidence_path(legal_aid_application))
        end
      end

      context "when setting is enabled" do
        let(:evidence_upload) { true }

        context "when at least one evidence type is required" do
          it "should redirect to the new upload evidence page" do
            expect(response).to redirect_to(providers_legal_aid_application_uploaded_evidence_collection_path(legal_aid_application))
          end
        end
      end
    end

    context "when evidence upload setting is on but no documents required" do
      let(:evidence_upload) { true }
      let(:legal_aid_application) { create :legal_aid_application, :with_proceedings, explicit_proceedings: [:da001] }
      let(:task_list) { create :legal_framework_merits_task_list, :da001, legal_aid_application: legal_aid_application }

      before do
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :latest_incident_details)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :opponent_details)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :children_application)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :statement_of_case)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:DA001, :chances_of_success)
        patch providers_legal_aid_application_merits_task_list_path(legal_aid_application)
      end

      it "redirects to the check merits answers page" do
        expect(response).to redirect_to(providers_legal_aid_application_check_merits_answers_path(legal_aid_application))
      end
    end

    context "when some tasks are incomplete" do
      subject { patch providers_legal_aid_application_merits_task_list_path(legal_aid_application) }

      it { expect(response).to have_http_status(:ok) }
      it { expect(response.body).to include("Provide details of the case") }
      it { expect(response.body).to include("There is a problem") }
    end
  end
end
