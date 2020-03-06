require 'rails_helper'

RSpec.describe 'about financial assessments requests', type: :request do
  let(:application) { create :legal_aid_application, :with_applicant }

  describe 'GET /providers/applications/:legal_aid_application_id/about_the_financial_assessment' do
    subject { get providers_legal_aid_application_application_confirmation_path(application) }
    before do
      login_as application.provider
      subject
    end

    it 'returns success' do
      expect(response).to be_successful
    end

    it 'displays application_ref' do
      expect(response.body).to include(application.application_ref)
    end
  end
end
