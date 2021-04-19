require 'rails_helper'

RSpec.describe Providers::MeritsTaskListsController, type: :request do
  let!(:pt1) { create :proceeding_type, ccms_code: 'DA005' }
  let!(:pt2) { create :proceeding_type, ccms_code: 'DA001' }
  let!(:pt3) { create :proceeding_type, ccms_code: 'DA003' }
  let(:login_provider) { login_as legal_aid_application.provider }
  let(:legal_aid_application) { create :legal_aid_application, :with_multiple_proceeding_types, proceeding_types: [pt1, pt2, pt3] }
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
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'displays a section for the whole application' do
        expect(response.body).to include('Case details')
      end

      it 'displays a section for all proceeding types linked to this application' do
        subject
        [pt1, pt2, pt3].pluck(:name).each do |name|
          expect(parsed_response_body.css("ol li#{name} h2").text).to match(/#{name}/)
        end
      end
    end

    context 'the record already exists' do
      before do
        login_provider
        create :legal_framework_merits_task, legal_aid_application: legal_aid_application
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
        [pt1, pt2, pt3].pluck(:name).each do |name|
          expect(parsed_response_body.css("ol li#{name} h2").text).to match(/#{name}/)
        end
      end
    end
  end
end
