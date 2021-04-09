require 'rails_helper'

RSpec.describe Providers::MeritsTaskListsController, type: :request do
  let!(:pt1) { create :proceeding_type }
  let!(:pt2) { create :proceeding_type }
  let!(:pt3) { create :proceeding_type }
  let(:login_provider) { login_as legal_aid_application.provider }
  let(:legal_aid_application) { create :legal_aid_application, :with_multiple_proceeding_types, proceeding_types: [pt1, pt2, pt3] }

  describe 'GET /providers/merits_task_list' do
    subject { get providers_legal_aid_application_merits_task_list_path(legal_aid_application) }

    before do
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
end
