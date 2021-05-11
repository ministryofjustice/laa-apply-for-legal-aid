require 'rails_helper'

RSpec.describe Providers::MeritsTaskListsController, type: :request do
  let(:login_provider) { login_as legal_aid_application.provider }
  let(:legal_aid_application) { create :legal_aid_application, :with_multiple_proceeding_types_inc_section8 }
  let(:proceeding_names) do
    legal_aid_application.application_proceeding_types.map do |type|
      ProceedingType.find(type.proceeding_type_id).meaning
    end
  end
  let(:smtl) { build :legal_framework_serializable_merits_task_list }

  subject { get providers_legal_aid_application_merits_task_list_path(legal_aid_application) }

  describe 'GET /providers/merits_task_list' do
    context 'the record does not exist' do
      before do
        allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
        login_provider
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
end
