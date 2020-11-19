require 'rails_helper'

RSpec.describe Admin::LegalAidApplications::SubmissionsController, type: :request do
  let(:admin_user) { create :admin_user }
  let(:legal_aid_application) { create(:legal_aid_application, :with_everything) }

  before { sign_in admin_user }

  describe 'GET show' do
    subject { get admin_legal_aid_applications_submission_path(legal_aid_application) }

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'displays correct application' do
      subject
      expect(response.body).to include(legal_aid_application.application_ref)
    end
  end
end
