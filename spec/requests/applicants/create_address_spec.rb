require 'rails_helper'

RSpec.describe 'POST /v1/applicants/:applicant_id/addresses', type: :request do
  let(:application) { create(:application, :with_applicant) }
  let(:applicant) { application.applicant }
  let(:application_id) { application.application_ref }
  let(:applicant_id) { applicant.id }
  let(:params) do
    {
      address_line_one: '123',
      address_line_two: 'High Street',
      city: 'London',
      county: 'Greater London',
      postcode: 'SW1H9AJ'
    }
  end
  let(:post_request) do
    -> { post "/v1/applicants/#{applicant_id}/addresses", params: params.to_json, headers: json_headers }
  end

  context 'when there is no applicant with the provided reference' do
    let(:applicant_id) { '0000' }

    it 'returns a 404 response' do
      post_request.call

      expect(response).to have_http_status(404)
      expect(response.content_type).to eq('application/json')
    end
  end

  context 'when some of the input params are not valid' do
    let(:params) do
      {
        address_line_one: '',
        address_line_two: 'High Street',
        city: 'London',
        county: 'Greater London',
        postcode: '1QQa5TF1'
      }
    end

    it 'returns a 400 response with the validation errors' do
      post_request.call

      expected_json = {
        errors: [
          { field: 'postcode', code: 'invalid' }
        ]
      }

      expect(response).to have_http_status(400)
      expect(response.content_type).to eq('application/json')
      expect(response.body).to match_json_expression(expected_json)
    end
  end

  it 'returns a successful address payload' do
    post_request.call

    expected_json = {
      id: Integer,
      address_line_one: '123',
      address_line_two: 'High Street',
      city: 'London',
      county: 'Greater London',
      postcode: 'SW1H9AJ',
      applicant_id: applicant_id,
      created_at: String,
      updated_at: String
    }

    expect(response).to have_http_status(201)
    expect(response.content_type).to eq('application/json')
    expect(response.body).to match_json_expression(expected_json)
  end

  it 'creates a new address' do
    expect { post_request.call }.to change { Address.count }.by(1)
  end
end
