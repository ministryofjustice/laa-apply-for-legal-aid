require 'rails_helper'

RSpec.describe V1::ProceedingTypesController, type: :request do
  describe 'GET /v1/proceeding_types' do
    context 'when no proceeding types are available' do
      let(:get_request) do
        -> { get '/v1/proceeding_types' }
      end
      it 'returns a successful response with an empty list' do
        get_request.call

        expected_json = []

        expect(response).to have_http_status(200)
        expect(response.media_type).to eq('application/json')
        expect(response.body).to match_json_expression(expected_json)
      end
    end

    context 'when there are proceeding types' do
      before do
        create(:proceeding_type,
               :with_real_data,
               code: 'PH0001',
               ccms_category_law: 'Family',
               ccms_matter: 'Public Law - Family',
               ccms_matter_code: 'KPBLB',
               meaning: 'Application for a care order',
               description: 'to be represented on an application for a care order.',
               additional_search_terms: '')
        create(:proceeding_type,
               :with_real_data,
               code: 'PH0002',
               ccms_code: 'PBM24',
               ccms_category_law: 'Other',
               ccms_matter: 'Public Law - Other',
               ccms_matter_code: 'APBLB',
               meaning: 'Not an application for a care order',
               description: 'Not to be represented on an application for a care order.',
               additional_search_terms: 'injunction')
        ProceedingType.refresh_textsearchable
      end

      context 'no search term is given' do
        let(:get_request) do
          -> { get '/v1/proceeding_types' }
        end

        it 'returns a successful response with a list of existent proceeding types' do
          get_request.call

          expected_json = [
            {
              code: 'PH0001',
              meaning: 'Application for a care order',
              description: 'to be represented on an application for a care order.',
              category_law: 'Family',
              matter: 'Public Law - Family',
              additional_search_terms: ''
            },
            {
              code: 'PH0002',
              meaning: 'Not an application for a care order',
              description: 'Not to be represented on an application for a care order.',
              category_law: 'Other',
              matter: 'Public Law - Other',
              additional_search_terms: 'injunction'
            }
          ]

          expect(response).to have_http_status(200)
          expect(response.media_type).to eql('application/json')
          expect(response.body).to match_json_expression(expected_json)
        end
      end

      context 'a search term is given and there are results' do
        search_term = 'injunction'
        let(:legal_aid_application) { create :legal_aid_application }
        let(:source_url) { providers_legal_aid_application_proceedings_types_path(legal_aid_application) }
        let(:get_request) do
          -> { get "/v1/proceeding_types?search_term=#{search_term}&sourceUrl=#{source_url}" }
        end

        it 'returns a successful response with just the proceeding types matching the search term' do
          get_request.call

          expected_json = [
            {
              code: 'PH0002',
              meaning: 'Not an application for a care order',
              description: 'Not to be represented on an application for a care order.',
              ccms_category_law: 'Other',
              ccms_matter: 'Public Law - Other'
            }
          ]

          expect(response).to have_http_status(200)
          expect(response.media_type).to eql('application/json')
          expect(response.body).to match_json_expression(expected_json)
        end
      end

      context 'a search term is given and there are no results' do
        search_term = 'harassment'
        let(:get_request) do
          -> { get "/v1/proceeding_types?search_term=#{search_term}" }
        end

        it 'returns a successful response with an empty list' do
          get_request.call

          expected_json = []

          expect(response).to have_http_status(200)
          expect(response.media_type).to eql('application/json')
          expect(response.body).to match_json_expression(expected_json)
        end
      end
    end
  end
end
