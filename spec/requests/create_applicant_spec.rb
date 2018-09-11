require 'rails_helper'
require 'json_expressions/rspec'

RSpec.describe 'Legal aid applications' do
  let(:response_json) { JSON.parse(response.body) }
  let(:application) { LegalAidApplication.create }
  let(:headers) do
    {
      'ACCEPT' => 'application/json',
      'HTTP_ACCEPT' => 'application/json',
      'Content-Type' => 'application/json'
    }
  end

  let(:body) do
    {
      'data': {
        'type': 'legal_aid_applicant',
        'attributes': {
          'name': 'John Doe',
          'date_of_birth': '1991-12-01',
          'application_ref': application.application_ref
        }
      }
    }.to_json
  end

  describe 'POST /v1/applicants' do
    it 'returns a successful applicant payload' do
      post '/v1/applicants', params: body, headers: headers
      expect(response.status).to eql(201)
      expect(response.content_type).to eql('application/json')
      expect(response_json['data']['attributes']['name']).to eq('John Doe')
      expect(response_json['data']['attributes']['date_of_birth']).to eq('1991-12-01')
    end

    it 'creates a new applicant' do
      expect do
        post '/v1/applicants', params: body, headers: headers
      end.to change { Applicant.count }.by(1)
    end

    context 'when the provided date of birth is invalid' do
      it 'returns an error' do
        body_invalid_date = {
          'data': {
            'type': 'legal_aid_applicant',
            'attributes': {
              'name': 'John Doe',
              'date_of_birth': '11-12-01',
              'application_ref': application.application_ref
            }
          }
        }.to_json
        post '/v1/applicants', params: body_invalid_date, headers: headers
        expect(response.status).to eql(400)
        expect(response.content_type).to eql('application/json')
        expect(response_json[0]).to eq('Date of birth is not valid')
      end
    end
  end
end
