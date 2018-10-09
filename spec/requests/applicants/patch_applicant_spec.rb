require 'rails_helper'

RSpec.describe 'PATCH /v1/applications/{app_ref}/applicant', type: :request do
  let(:applicant) { application.applicant }
  let(:application) { create(:application, :with_applicant) }
  let(:application_id) { application.application_ref }
  let(:params) { { email_address: 'new_email@test.com' } }
  let(:patch_request) do
    -> { patch "/v1/applications/#{application_id}/applicant/", params: params.to_json, headers: json_headers }
  end

  context 'when the application with the provided id does not exist' do
    let(:application_id) { SecureRandom.uuid }

    it 'returns a 404 response' do
      patch_request.call

      expect(response).to have_http_status(404)
      expect(response.content_type).to eq('application/json')
    end
  end

  context 'when the application has no applicant associated to it' do
    let(:application) { create(:application, applicant: nil) }

    it 'returns a 404 response' do
      patch_request.call

      expect(response).to have_http_status(404)
      expect(response.content_type).to eq('application/json')
    end
  end

  context 'when some of the params are not valid' do
    let(:params) { { email_address: 'this-is-not-a-valid-email' } }

    it 'returns a 400 response with the validation errors' do
      patch_request.call

      expected_json = {
        errors: [
          { field: 'email_address', code: 'invalid' }
        ]
      }

      expect(response).to have_http_status(400)
      expect(response.content_type).to eq('application/json')
      expect(response.body).to match_json_expression(expected_json)
    end
  end

  it 'updates email address on applicant with given application ref' do
    patch_request.call

    expected_json = {
      first_name: applicant.first_name,
      last_name: applicant.last_name,
      email_address: 'new_email@test.com',
      date_of_birth: applicant.date_of_birth.to_s,
      national_insurance_number: applicant.national_insurance_number
    }

    expect(response).to have_http_status(200)
    expect(response.content_type).to eq('application/json')
    expect(response.body).to match_json_expression(expected_json)
  end
end
