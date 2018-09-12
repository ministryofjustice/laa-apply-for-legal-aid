require 'rails_helper'
require 'json_expressions/rspec'

RSpec.describe 'Proceeding types' do
  describe 'GET proceeding_types' do
    let!(:proceeding_type) do
      ProceedingType.create(code: 'PH0001',
                            ccms_code: 'PBM23',
                            ccms_category_law: 'Family',
                            ccms_category_law_code: 'MAT',
                            ccms_matter: 'Public Law - Family',
                            ccms_matter_code: 'KPBLB',
                            meaning: 'Application for a care order',
                            description: 'to be represented on an application for a care order.')
    end

    it 'returns a proceeding types' do
      get '/proceeding_types'

      expected_json =

        {
          'data' => [{
            'id' => proceeding_type.id.to_s,
            'type' => 'proceeding_types',
            'attributes' => {
              'proceeding_type_code' => 'PH0001',
              'ccms_category_law' => 'Family',
              'ccms_matter' => 'Public Law - Family',
              'meaning' => 'Application for a care order',
              'description' => 'to be represented on an application for a care order.'
            }
          }]
        }

      expect(response.body).to match_json_expression(expected_json)
      expect(response.status).to eql(200)
      expect(response.content_type).to eql('application/json')
    end
  end
end
