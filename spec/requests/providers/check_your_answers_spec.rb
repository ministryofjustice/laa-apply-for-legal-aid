require 'rails_helper'

RSpec.describe 'check your answers requests', type: :request do
  let(:application) { create(:legal_aid_application, :with_applicant) }
  let(:application_id) { application.id }

  describe 'GET /providers/applications/:legal_aid_application_id/check_your_answers' do
    let(:get_request) { get "/providers/applications/#{application_id}/check_your_answers" }

    context 'when the application does not exist' do
      let(:application_id) { SecureRandom.uuid }

      it 'redirects to the applications page with an error' do
        get_request

        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end
    end

    it 'returns success' do
      get_request

      expect(response).to be_successful
      expect(unescaped_response_body).to include('Check your answers')
    end
  end

  describe 'GET /providers/applications/:legal_aid_application_id/check_your_answers/confirm' do
    let(:get_request) { get "/providers/applications/#{application_id}/check_your_answers/confirm" }
    let(:mocked_email_service) { instance_double(CitizenEmailService) }

    context 'when the application does not exist' do
      let(:application_id) { SecureRandom.uuid }

      it 'redirects to the applications page without calling the email service' do
        expect(CitizenEmailService).not_to receive(:new)

        get_request

        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end
    end

    it 'redirects to the application page after calling the email service' do
      expect(CitizenEmailService).to receive(:new).with(application).and_return(mocked_email_service)
      expect(mocked_email_service).to receive(:send_email)

      get_request
      expect(response).to redirect_to(providers_legal_aid_applications_path)
    end
  end
end
