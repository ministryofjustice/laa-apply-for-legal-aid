require 'rails_helper'
require 'json_expressions/rspec'

RSpec.describe 'Create Legal aid applications' do
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
          'first_name': 'John',
          'last_name': 'Doe',
          'date_of_birth': '1991-12-01',
          'national_insurance_number': 'AB123456D',
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
      expect(response_json.dig('data', 'attributes', 'first_name')).to eq('John')
      expect(response_json.dig('data', 'attributes', 'last_name')).to eq('Doe')
      expect(response_json.dig('data', 'attributes', 'date_of_birth')).to eq('1991-12-01')
      expect(response_json.dig('data', 'attributes', 'national_insurance_number')).to eq('AB123456D')
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
              'first_name': 'John',
              'last_name': 'Doe',
              'date_of_birth': '11-12-01',
              'national_insurance_number': 'AB123456D',
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

RSpec.describe 'Update Legal aid applications' do
  let(:response_json) { JSON.parse(response.body) }
  let!(:existing_applicant) do
    Applicant.create(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name,
                     date_of_birth: Faker::Date.birthday(18, 100), national_insurance_number: 'AB123456D')
  end
  let!(:application) { LegalAidApplication.create(applicant: existing_applicant) }
  let!(:application_without_applicant) { LegalAidApplication.create }

  let(:headers) do
    {
      'ACCEPT' => 'application/json',
      'HTTP_ACCEPT' => 'application/json',
      'Content-Type' => 'application/json'
    }
  end

  describe 'PATCH /v1/applications/{app_ref}/applicant' do
    body = {
      'data': {
        'type': 'legal_aid_applicant',
        'attributes': {
          'email_address': 'test@test.com'
        }
      }
    }.to_json

    it 'updates email address on applicant with given application ref' do
      expected_json = {
        "data": {
          "id": existing_applicant.id.to_s,
          "type": 'applicant',
          "attributes": {
            "first_name": existing_applicant.first_name,
            "last_name": existing_applicant.last_name,
            "email_address": 'test@test.com',
            "national_insurance_number": existing_applicant.national_insurance_number,
            "date_of_birth": existing_applicant.date_of_birth.to_s
          }
        }
      }

      patch "/v1/applications/#{application.application_ref}/applicant/", params: body, headers: headers

      expect(response.status).to eql(200)
      expect(response_json).to match_json_expression(expected_json)
    end

    it 'returns correct error for invalid email format' do
      body_invalid_email = {
        'data': {
          'type': 'legal_aid_applicant',
          'attributes': {
            'email_address': 'asdfg'
          }
        }
      }.to_json
      patch "/v1/applications/#{application.application_ref}/applicant/", params: body_invalid_email, headers: headers
      expect(response.status).to eql(400)
      expect(response.content_type).to eql('application/json')
      expect(response_json[0]).to eq('Email address is not in the right format')
    end

    it 'returns a 422 if a application is not found' do
      patch "/v1/applications/this-ref-doesn't-exist/applicant/", params: body, headers: headers
      expect(response.status).to eql(422)
      expect(response_json['message']).to eql("Failed to find application with ref this-ref-doesn't-exist")
    end

    it 'returns a 404 if a applicant for application is not found' do
      patch "/v1/applications/#{application_without_applicant.application_ref}/applicant/", params: body, headers: headers
      expect(response.status).to eql(404)
      expect(response_json['message']).to eql("Failed to find applicant for application with ref #{application_without_applicant.application_ref}")
    end
  end
end
