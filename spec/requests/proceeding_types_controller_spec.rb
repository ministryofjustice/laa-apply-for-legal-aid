require 'rails_helper'
require 'json_expressions/rspec'

RSpec.describe 'Proceeding types' do
  describe 'GET proceeding_types' do
    let!(:first_proceeding_types) do
      ProceedingType.create(code: 'PH0001',
                            ccms_code: 'PBM23',
                            ccms_category_law: 'Family',
                            ccms_category_law_code: 'MAT',
                            ccms_matter: 'Public Law - Family',
                            ccms_matter_code: 'KPBLB',
                            meaning: 'Application for a care order',
                            description: 'to be represented on an application for a care order.')
    end

    let!(:second_proceeding_types) do
      ProceedingType.create(code: 'PH0002',
                            ccms_code: 'PBM24',
                            ccms_category_law: 'Family2',
                            ccms_category_law_code: 'MAT2',
                            ccms_matter: 'Public Law - Family2',
                            ccms_matter_code: 'APBLB',
                            meaning: 'Not an application for a care order',
                            description: 'Not to be represented on an application for a care order.')
    end

    it 'returns a proceeding types' do
      get '/proceeding_types'

      expected_json =

        {
          'data' => [
            {
              'id' => first_proceeding_types.id.to_s,
              'type' => 'proceeding_types',
              'attributes' => {
                'code' => 'PH0001',
                'meaning' => 'Application for a care order',
                'description' => 'to be represented on an application for a care order.',
                'category_law' => 'Family',
                'matter' => 'Public Law - Family'
              }
            },
            {
              'id' => second_proceeding_types.id.to_s,
              'type' => 'proceeding_types',
              'attributes' => {
                'code' => 'PH0002',
                'meaning' => 'Not an application for a care order',
                'description' => 'Not to be represented on an application for a care order.',
                'category_law' => 'Family2',
                'matter' => 'Public Law - Family2'
              }
            }
          ]
        }

      expect(response.body).to match_json_expression(expected_json)
      expect(response.status).to eql(200)
      expect(response.content_type).to eql('application/json')
    end
  end
end
