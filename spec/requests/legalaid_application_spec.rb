require 'rails_helper'
require 'json_expressions/rspec'

RSpec.describe 'Legal aid applications' do
  let(:response_json) { JSON.parse(response.body) }

  describe 'POST /v1/applications' do
    it 'returns an application reference' do
      post '/v1/applications'
      expect(response_json['data']['attributes']['application_ref']).not_to be_empty
      expect(response.status).to eql(201)
      expect(response.content_type).to eql('application/json')
    end
  end

  describe 'GET /v1/applications/:id' do
    let(:applicant_name) { Faker::Name.name }
    let(:applicant_date_of_birth) { Faker::Date.birthday(18, 100) }
    let(:applicant) { Applicant.create(name: applicant_name, date_of_birth: applicant_date_of_birth) }
    let(:legal_aid_application) { LegalAidApplication.create(applicant: applicant) }
    let(:application_ref) { legal_aid_application.application_ref }

    context 'with a non-existant application reference' do
      let(:application_ref) { SecureRandom.uuid }

      it 'returns a 404 error' do
        get '/v1/applications/' + application_ref
        expect(response.status).to eql(404)
        expect(response.content_type).to eql('application/json')
      end
    end

    it 'returns a complete application' do
      get '/v1/applications/' + application_ref

      expected_json = {
        'data' =>
          { 'id' => legal_aid_application.id.to_s,
            'type' => 'legal_aid_application',
            'attributes' =>
              { 'application_ref' => application_ref },
            'relationships' =>
                { 'applicant' =>
                  { 'data' =>
                    { 'id' => applicant.id.to_s,
                      'type' => 'applicant' } } } },
        'included' => [
          { 'id' => applicant.id.to_s,
            'type' => 'applicant',
            'attributes' =>
            { 'name' => applicant_name,
              'date_of_birth' => applicant_date_of_birth.to_s } }
        ]
      }

      expect(response.body).to match_json_expression(expected_json)
      expect(response.status).to eql(200)
      expect(response.content_type).to eql('application/json')
    end

    context 'when proceedings are saved along with application' do
      it 'creates a new legal aid application' do
        expect do
          post '/v1/applications', params: { proceedings_attributes: [{ code: 'PR0001' }] }
        end.to change { LegalAidApplication.count }.by(1)
      end

      xit 'associates provided proceedings with newly created legal aid application' do
        post '/v1/applications', params: { proceedings_attributes: [{ code: 'PR0001' }] }
        application_ref = response_json['data']['attributes']['application_ref']
        expect(LegalAidApplication.find_by(application_ref: application_ref).proceedings.size).to eq(1)
      end
    end
  end
end
