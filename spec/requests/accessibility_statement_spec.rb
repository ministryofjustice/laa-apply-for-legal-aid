require 'rails_helper'

RSpec.describe 'accessibility statement page', type: :request do
  describe 'GET /accessibility_statement' do
    it 'returns renders successfully' do
      get accessibility_statement_index_path
      expect(response).to have_http_status(:ok)
    end

    it 'display accessibility information' do
      get accessibility_statement_index_path
      expect(response.body).to include(I18n.t('accessibility_statement.index.testing.heading'))
      expect(response.body).to include(I18n.t('accessibility_statement.index.ehrc.heading'))
      expect(response.body).to include(I18n.t('accessibility_statement.index.accessibility.problems'))
    end
  end
end
