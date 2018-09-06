require 'rails_helper'
require 'json_expressions/rspec'

RSpec.describe 'Legal aid applications' do
  let(:response_json) { JSON.parse(response.body) }
  let(:application_ref) {'f4729006-dd96-4fe5-b2f4-42ef9190c796'}

  describe 'POST /v1/applicants' do
    it 'returns a successful applicant payload' do
    existing_ref = LegalAidApplication.create.application_ref
      headers = {
      "ACCEPT" => "application/json",
      "HTTP_ACCEPT" => "application/json",
      'Content-Type' => 'application/json'
    }
      post '/v1/applicants', params:
      {
        'data': {
          'type': 'legal_aid_applicant',
          'attributes': {
            'name': 'John Doe',
            'date_of_birth': '1991-12-01',
            'application_ref': existing_ref
          }
        }
      }.to_json ,
      headers: headers
      expect(response.status).to eql(201)
      expect(response.content_type).to eql('application/json')
      expect(response_json['data']['attributes']['name']).to eq('John Doe')
      expect(response_json['data']['attributes']['date_of_birth']).to eq('1991-12-01')
      expect(response_json['data']['attributes']['application_ref']).to eq(existing_ref)
    end

    it 'creates a new applicant' do
      headers = {
      "ACCEPT" => "application/json",
      "HTTP_ACCEPT" => "application/json",
      'Content-Type' => 'application/json'
    }

    body =  {
        'data': {
          'type': 'legal_aid_applicant',
          'attributes': {
            'name': 'John Doe',
            'date_of_birth': '1991-12-01',
            'application_ref': application_ref
          }
        }
      }.to_json
      expect {
        post '/v1/applicants', params: body , headers: headers
      }.to change { Applicant.where(name: "John Doe", date_of_birth: "1991-12-01").count }.by(1)
    end

    context "when the provided date of birth is invalid" do
      it "returns an error" do
          headers = {
          "ACCEPT" => "application/json",
          "HTTP_ACCEPT" => "application/json",
          'Content-Type' => 'application/json'
        }

        body =  {
            'data': {
              'type': 'legal_aid_applicant',
              'attributes': {
                'name': 'John Doe',
                'date_of_birth': '11-12-01',
                'application_ref': application_ref
              }
            }
          }.to_json
          post '/v1/applicants', params: body , headers: headers
          expect(response.status).to eql(400)
          expect(response.content_type).to eql('application/json')
          expect(response_json['date_of_birth']).to include('Date of birth is not valid')
      end
    end
  end
end
