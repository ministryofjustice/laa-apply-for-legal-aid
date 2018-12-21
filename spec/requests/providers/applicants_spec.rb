require 'rails_helper'

RSpec.describe 'providers applicant requests', type: :request do
  let(:application) { create(:legal_aid_application) }
  let(:application_id) { application.id }

  describe 'GET /providers/applications/:legal_aid_application_id/applicant' do
    let(:get_request) { get "/providers/applications/#{application_id}/applicant" }

    it 'returns http success' do
      get_request
      expect(response).to have_http_status(:ok)
    end

    context 'when the application does not exist' do
      let(:application_id) { SecureRandom.uuid }

      it 'redirects the user to the applications page with an error message' do
        get_request

        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end
    end

    context 'has already got applicant infro' do
      let(:applicant) { create(:applicant) }
      let(:laa) { create(:legal_aid_application, applicant: applicant) }
      let(:get_request) { get "/providers/applications/#{laa.id}/applicant" }

      it 'display first_name' do
        get_request
        expect(unescaped_response_body).to include(applicant.first_name)
      end
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/applicant' do
    let(:params) do
      {
        applicant: {
          first_name: 'John',
          last_name: 'Doe',
          national_insurance_number: 'AA 12 34 56 C',
          dob_year: '1981',
          dob_month: '07',
          dob_day: '11',
          email: Faker::Internet.safe_email
        },
        'continue-button' => 'Continue'
      }
    end
    let(:patch_request) { patch "/providers/applications/#{application_id}/applicant", params: params }

    it 'redirects provider to next step of the submission' do
      patch_request

      expect(response).to redirect_to(providers_legal_aid_application_address_lookup_path(application))
    end

    it 'creates a new applicant associated with the application' do
      expect { patch_request }.to change { Applicant.count }.by(1)

      new_applicant = application.reload.applicant
      expect(new_applicant).to be_instance_of(Applicant)
    end

    context 'when the legal aid application is in checking_answers state' do
      let(:application) { create(:legal_aid_application, state: :checking_answers) }

      it 'redirects to check_your_answers page' do
        patch_request

        expect(response).to redirect_to(providers_legal_aid_application_check_provider_answers_path)
      end
    end

    context 'when the application does not exist' do
      let(:application_id) { SecureRandom.uuid }

      it 'redirects the user to the applications page with an error message' do
        patch_request

        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end

      it 'does NOT create a new applicant' do
        expect { patch_request }.not_to change { Applicant.count }
      end
    end

    context 'when the params are not valid' do
      let(:params) do
        {
          applicant: {
            first_name: '',
            last_name: 'Doe',
            national_insurance_number: 'AA 12 34 56 C',
            dob_year: '1981',
            dob_month: '07',
            dob_day: '11',
            email: Faker::Internet.safe_email
          }
        }
      end

      it 'renders the form page displaying the errors' do
        patch_request

        expect(unescaped_response_body).to include('There is a problem')
        expect(unescaped_response_body).to include('Enter first name')
      end

      it 'does NOT create a new applicant' do
        expect { patch_request }.not_to change { Applicant.count }
      end
    end

    context 'when params dont have continue or save as draft button' do
      it 'raises' do
        params.delete('continue-button')
        expect {
          patch_request
        }.to raise_error RuntimeError, 'No continue or Save as draft button when expected'
      end
    end
  end
end
