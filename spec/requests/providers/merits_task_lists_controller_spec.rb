require 'rails_helper'

RSpec.describe Providers::MeritsTaskListsController, type: :request do
  let(:login_provider) { login_as legal_aid_application.provider }
  let(:pt_da) { create :proceeding_type, :with_real_data }
  let(:pt_s8) { create :proceeding_type, :as_section_8_child_residence }
  let(:legal_aid_application) do
    create :legal_aid_application,
           :with_proceeding_types,
           explicit_proceeding_types: [pt_da, pt_s8]
  end

  let(:proceeding_names) do
    legal_aid_application.application_proceeding_types.map do |type|
      ProceedingType.find(type.proceeding_type_id).meaning
    end
  end
  let(:task_list) { create :legal_framework_merits_task_list, legal_aid_application: legal_aid_application }

  before do
    legal_aid_application
    allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(task_list)
    login_provider
    subject
  end

  describe 'GET /providers/merits_task_list' do
    subject { get providers_legal_aid_application_merits_task_list_path(legal_aid_application) }
    context 'the record does not exist' do
      let(:task_list) { build :legal_framework_serializable_merits_task_list }

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'displays a section for the whole application' do
        expect(response.body).to include('Case details')
      end

      it 'displays a section for all proceeding types linked to this application' do
        proceeding_names.each { |name| expect(response.body).to include(name) }
      end
    end

    context 'the record already exists' do
      before do
        login_provider
        create :legal_framework_merits_task_list, legal_aid_application: legal_aid_application
        subject
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'displays a section for the whole application' do
        expect(response.body).to include('Case details')
      end

      it 'displays a section for all proceeding types linked to this application' do
        subject
        proceeding_names.each { |name| expect(response.body).to include(name) }
      end
    end
  end

  describe 'PATCH /providers/merits_task_list' do
    context 'when all tasks are complete' do
      before do
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :latest_incident_details)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :opponent_details)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :children_application)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:DA001, :chances_of_success)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:SE014, :chances_of_success)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:SE014, :children_proceeding)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:SE014, :attempts_to_settle)
        patch providers_legal_aid_application_merits_task_list_path(legal_aid_application)
      end

      it 'redirects to the gateway evidence page' do
        expect(response).to redirect_to(providers_legal_aid_application_gateway_evidence_path(legal_aid_application))
      end
    end

    context 'when some tasks are incomplete' do
      subject { patch providers_legal_aid_application_merits_task_list_path(legal_aid_application) }

      it { expect(response).to have_http_status(:ok) }
      it { expect(response.body).to include('Provide details of the case') }
      it { expect(response.body).to include('There is a problem') }
    end
  end
end
