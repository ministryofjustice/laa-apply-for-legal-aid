require 'rails_helper'

RSpec.describe 'providers email requests', type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe 'GET /providers/applications/:legal_aid_application_id/email' do
    subject { get providers_legal_aid_application_email_path(legal_aid_application) }

    it 'returns http success' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'renders the next page' do
      subject
      expect(response.body).to include("What is your client's email address?")
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/email' do
    let(:original_email) { Faker::Internet.safe_email }
    let(:new_email) { Faker::Internet.safe_email }
    let(:applicant) { create(:applicant, email: original_email) }
    let(:legal_aid_application) { create(:legal_aid_application, applicant: applicant) }
    let(:params) do
      { applicant: { email: new_email } }
    end

    subject { patch providers_legal_aid_application_email_path(legal_aid_application), params: params }

    it 'updates the applicant' do
      expect { subject }
        .to change { applicant.reload.email }
        .from(original_email).to(new_email)
    end

    it 'redirects to the check your answers page' do
      subject
      expect(response).to redirect_to(providers_legal_aid_application_check_your_answers_path(legal_aid_application))
    end

    context 'when the application does not exist' do
      let(:legal_aid_application) { SecureRandom.uuid }

      it 'redirects the user to the applications page with an error message' do
        subject
        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end

      it 'does NOT update the applicant' do
        expect { subject }.not_to change { applicant.reload.email }
      end
    end

    context 'when params are not valid' do
      let(:new_email) { 'not-a-valid-email' }

      it 'does NOT update the applicant' do
        expect { subject }.not_to change { applicant.reload.email }
      end

      it 're-renders the form with the validation errors' do
        subject

        expect(unescaped_response_body).to include('There is a problem')
        expect(unescaped_response_body).to include('Enter an email address in the right format')
      end
    end

    context 'with an existing applicant with the same email' do
      let!(:existing_applicant) { create :applicant, email: new_email }

      it 'updates the applicant' do
        expect { subject }
          .to change { applicant.reload.email }
          .from(original_email).to(new_email)
      end

      it 'redirects to the check your answers page' do
        subject
        expect(response).to redirect_to(providers_legal_aid_application_check_your_answers_path(legal_aid_application))
      end
    end
  end
end
