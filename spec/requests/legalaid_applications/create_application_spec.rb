require 'rails_helper'

RSpec.describe 'POST /v1/applications', type: :request do
  context 'when no params are provided' do
    it 'creates a new legal application record' do
      expect {
        post '/v1/applications', headers: json_headers
      }.to change { LegalAidApplication.count }.by(1)
    end

    it 'returns a successful response with the payload for the application' do
      post '/v1/applications', headers: json_headers

      new_application = LegalAidApplication.last
      expected_json = {
        id: new_application.application_ref,
        applicant: nil,
        proceeding_types: []
      }

      expect(response).to have_http_status(201)
      expect(response.content_type).to eq('application/json')
      expect(response.body).to match_json_expression(expected_json)
    end
  end

  context 'when proceedings are saved along with application reference' do
    let(:proceeding_types) do
      [
        create(:proceeding_type,
               code: 'PR0001',
               meaning: 'test meaning1',
               description: 'test desc1',
               ccms_category_law: 'bla',
               ccms_matter: 'matter1'),
        create(:proceeding_type,
               code: 'PR0002',
               meaning: 'test meaning2',
               description: 'test desc2',
               ccms_category_law: 'law2',
               ccms_matter: 'matter2')
      ]
    end
    let(:proceeding_type_codes) { proceeding_types.map(&:code) }
    let(:params) { { proceeding_type_codes: proceeding_type_codes } }
    let(:post_request) do
      -> { post '/v1/applications', params: params.to_json, headers: json_headers }
    end

    it 'creates a new legal aid application associated with the proceeding types provided' do
      expect {
        post_request.call
      }.to change { LegalAidApplication.count }.by(1)

      application_ref = json['id']
      new_application = LegalAidApplication.find_by(application_ref: application_ref)
      expect(new_application.proceeding_types.map(&:code)).to match_array(proceeding_type_codes)
    end

    it 'returns the application payload including the associated proceeding types' do
      post_request.call

      new_application = LegalAidApplication.last
      expected_json = {
        id: new_application.application_ref,
        applicant: nil,
        proceeding_types: [
          {
            code: 'PR0001',
            meaning: 'test meaning1',
            description: 'test desc1',
            category_law: 'bla',
            matter: 'matter1'
          },
          {
            code: 'PR0002',
            meaning: 'test meaning2',
            description: 'test desc2',
            category_law: 'law2',
            matter: 'matter2'
          }
        ]
      }

      expect(response).to have_http_status(201)
      expect(response.content_type).to eq('application/json')
      expect(response.body).to match_json_expression(expected_json)
    end

    context 'when the proceeding type codes are not valid' do
      let(:params) { { proceeding_type_codes: ['invalid_proceeding_type_code'] } }

      it 'returns a bad data payload' do
        post '/v1/applications', params: params.to_json, headers: json_headers

        expected_json = {
          errors: [
            { field: 'proceeding_type_codes', code: 'invalid' }
          ]
        }

        expect(response).to have_http_status(400)
        expect(response.content_type).to eq('application/json')
        expect(response.body).to match_json_expression(expected_json)
      end
    end
  end
end
