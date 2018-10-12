require 'rails_helper'

RSpec.describe 'POST /v1/applications/:application_id/applicant', type: :request do
  let(:application) { create(:application) }
  let(:application_id) { application.application_ref }
  let(:params) do
    {
      first_name: 'John',
      last_name: 'Doe',
      date_of_birth: '1991-12-01',
      national_insurance_number: 'BH134435M'
    }
  end
  let(:post_request) do
    -> { post "/v1/applications/#{application_id}/applicant", params: params.to_json, headers: json_headers }
  end

  context 'when there is no application with the provided reference' do
    let(:application_id) { SecureRandom.uuid }

    it 'returns a 404 response' do
      post_request.call

      expect(response).to have_http_status(404)
      expect(response.content_type).to eq('application/json')
    end
  end

  context 'when some of the input params are not valid' do
    let(:params) do
      {
        first_name: '',
        last_name: 'Doe',
        date_of_birth: '11-12-01',
        national_insurance_number: 'BH134435M'
      }
    end

    it 'returns a 400 response with the validation errors' do
      post_request.call

      expected_json = {
        errors: [
          { field: 'first_name', code: 'blank' },
          { field: 'date_of_birth', code: 'invalid' }
        ]
      }

      expect(response).to have_http_status(400)
      expect(response.content_type).to eq('application/json')
      expect(response.body).to match_json_expression(expected_json)
    end
  end

  it 'returns a successful applicant payload' do
    post_request.call

    expected_json = {
      id: Applicant.last.id,
      first_name: 'John',
      last_name: 'Doe',
      date_of_birth: '1991-12-01',
      email_address: nil,
      national_insurance_number: 'BH134435M'
    }

    expect(response).to have_http_status(201)
    expect(response.content_type).to eql('application/json')
    expect(response.body).to match_json_expression(expected_json)
  end

  it 'creates a new applicant' do
    expect { post_request.call }.to change { Applicant.count }.by(1)
  end
end
