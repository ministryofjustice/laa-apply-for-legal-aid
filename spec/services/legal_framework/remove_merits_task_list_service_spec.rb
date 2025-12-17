require "rails_helper"

RSpec.describe LegalFramework::RemoveMeritsTaskListService do
  subject(:call_service) { described_class.call(legal_aid_application) }

  let(:legal_aid_application) do
    create(:legal_aid_application,
           :with_proceedings,
           :with_everything,
           :with_involved_children,
           :with_attempts_to_settle,
           :with_chances_of_success,
           :with_opponents_application_proceeding,
           :with_prohibited_steps,
           :with_specific_issue,
           :with_vary_order,
           in_scope_of_laspo: true,
           proceeding_count: 3)
  end
  let(:smtl) { create(:legal_framework_merits_task_list, :da001_da004_se014, legal_aid_application:) }

  before { allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl) }

  describe ".call" do
    subject(:call) { described_class.call(legal_aid_application) }

    let(:merits_task_list_remover) { instance_double(described_class) }

    before do
      allow(described_class).to receive(:new).and_return(merits_task_list_remover)
      allow(merits_task_list_remover).to receive(:call)
    end

    it "calls self#call" do
      call
      expect(described_class).to have_received(:new).with(legal_aid_application)
      expect(merits_task_list_remover).to have_received(:call)
    end
  end

  describe "#call" do
    it "deletes the legal_framework_merits_task_list" do
      expect { call_service }.to change(LegalFramework::MeritsTaskList, :count).by(-1)
      expect(legal_aid_application.reload.legal_framework_merits_task_list).to be_nil
    end

    it "deletes the application's merits task list answers" do
      create(:allegation, :with_data, legal_aid_application: legal_aid_application)
      create(:matter_opposition, legal_aid_application: legal_aid_application)
      create(:undertaking, :with_data, legal_aid_application: legal_aid_application)
      create(:urgency, legal_aid_application: legal_aid_application)
      create(:appeal, legal_aid_application: legal_aid_application)

      expect { call_service }.to change { legal_aid_application.reload.opponents.count }.from(1).to(0)
      .and change { legal_aid_application.involved_children.count }.from(3).to(0)
      .and change(legal_aid_application, :domestic_abuse_summary).to(nil)
      .and change(legal_aid_application, :latest_incident).to(nil)
      .and change(legal_aid_application, :parties_mental_capacity).to(nil)
      .and change(legal_aid_application, :statement_of_case).to(nil)
      .and change(legal_aid_application, :allegation).to(nil)
      .and change(legal_aid_application, :matter_opposition).to(nil)
      .and change(legal_aid_application, :undertaking).to(nil)
      .and change(legal_aid_application, :urgency).to(nil)
      .and change(legal_aid_application, :appeal).to(nil)
      .and change(legal_aid_application, :in_scope_of_laspo).from(true).to(nil)
      .and change(ApplicationMeritsTask::Opponent, :count).by(-1)
      .and change(ApplicationMeritsTask::InvolvedChild, :count).by(-3)
      .and change(ApplicationMeritsTask::DomesticAbuseSummary, :count).by(-1)
      .and change(ApplicationMeritsTask::Incident, :count).by(-1)
      .and change(ApplicationMeritsTask::PartiesMentalCapacity, :count).by(-1)
      .and change(ApplicationMeritsTask::StatementOfCase, :count).by(-1)
      .and change(ApplicationMeritsTask::Allegation, :count).by(-1)
      .and change(ApplicationMeritsTask::MatterOpposition, :count).by(-1)
      .and change(ApplicationMeritsTask::Undertaking, :count).by(-1)
      .and change(ApplicationMeritsTask::Urgency, :count).by(-1)
      .and change(ApplicationMeritsTask::Appeal, :count).by(-1)
    end

    it "deletes proceeding merits task answers successfully" do
      expect { call_service }
      .to change { legal_aid_application.reload.proceedings.any?(&:attempts_to_settle) }.from(true).to(false)
      .and change { legal_aid_application.proceedings.any?(&:chances_of_success) }.from(true).to(false)
      .and change { legal_aid_application.proceedings.any?(&:opponents_application) }.from(true).to(false)
      .and change { legal_aid_application.proceedings.any?(&:prohibited_steps) }.from(true).to(false)
      .and change { legal_aid_application.proceedings.any?(&:specific_issue) }.from(true).to(false)
      .and change { legal_aid_application.proceedings.any?(&:vary_order) }.from(true).to(false)
    end
  end
end
