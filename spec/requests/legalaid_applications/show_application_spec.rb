require 'rails_helper'

RSpec.describe 'GET /v1/applications/:id', type: :request do
  let(:applicant) { legal_aid_application.applicant }
  let(:legal_aid_application) { create(:application, :with_applicant) }
  let(:application_ref) { legal_aid_application.application_ref }
  let(:get_request) do
    -> { get "/v1/applications/#{application_ref}", headers: json_headers }
  end

  context 'with a non-existant application reference' do
    let(:application_ref) { SecureRandom.uuid }

    it 'returns a 404 response' do
      get_request.call

      expect(response).to have_http_status(404)
      expect(response.content_type).to eql('application/json')
    end
  end

  it 'returns a complete application' do
    get_request.call

    expected_json = {
      id: application_ref,
      applicant: {
        id: applicant.id,
        first_name: applicant.first_name,
        last_name: applicant.last_name,
        date_of_birth: applicant.date_of_birth.to_s(:db),
        email: applicant.email,
        national_insurance_number: applicant.national_insurance_number
      },
      proceeding_types: []
    }

    expect(response).to have_http_status(200)
    expect(response.content_type).to eql('application/json')
    expect(response.body).to match_json_expression(expected_json)
  end
end
