require 'rails_helper'

RSpec.describe 'citizen home requests', type: :request do
  let(:application) { create :application, :with_applicant, completed_at: completed_at }
  let(:application_id) { application.id }
  let(:secure_id) { application.generate_secure_id }
  let(:applicant_first_name) { application.applicant.first_name }
  let(:applicant_last_name) { application.applicant.last_name }
  let(:completed_at) { nil }

  describe 'GET citizens/applications/:id' do
    before { get citizens_legal_aid_application_path(secure_id) }

    it 'redirects to applications' do
      expect(response).to redirect_to(citizens_legal_aid_applications_path)
    end

    context 'the link is not set to expire' do
      let(:secure_id) do
        SecureData.create_and_store!(
          legal_aid_application: { id: application_id }
        )
      end

      it 'redirects to applications' do
        expect(response).to redirect_to(citizens_legal_aid_applications_path)
      end
    end

    context 'when no matching legal aid application exists' do
      let(:secure_id) { SecureRandom.uuid }

      it 'redirects to page not found error' do
        expect(response).to redirect_to(error_path(:page_not_found))
      end
    end

    context 'when applicant has completed the means assessment' do
      let(:completed_at) { Faker::Time.backward }

      it 'redirects to expired page (completed_at is not null)' do
        # TO DO when correct path is known
        # expect(response).to redirect_to(path_to_be_determined)
        expect(response.body).to include('Expired Page - completed the application')
      end
    end

    context 'when applicant has not used the link within 7 days' do
      let(:secure_id) do
        SecureData.create_and_store!(
          legal_aid_application: { id: application_id },
          expired_at: Time.current - 1.minute
        )
      end

      it 'redirects to expired page (7 days)' do
        # TO DO when correct path is known
        # expect(response).to redirect_to(path_to_be_determined)
        expect(response.body).to include('Expired Page - missed url expiry in 7 day window')
      end
    end
  end

  describe 'GET citizens/applications' do
    subject do
      get citizens_legal_aid_application_path(secure_id)
      get citizens_legal_aid_applications_path
    end

    context 'when there is a legal aid application that matches the secure data' do
      it 'returns http success' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'sets the application_id session variable' do
        subject
        expect(session[:current_application_id]).to eq(application_id)
      end

      it 'returns the correct application' do
        subject
        expect(unescaped_response_body).to include(applicant_first_name.html_safe)
        expect(unescaped_response_body).to include(applicant_last_name.html_safe)
      end

      context 'if a provider is logged in' do
        let(:provider) { create :provider }
        before { sign_in provider }

        it 'logs out the provider' do
          subject
          expect(unescaped_response_body).not_to include(provider.username)
        end
      end
    end
  end
end
