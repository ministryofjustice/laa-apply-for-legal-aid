require 'rails_helper'

RSpec.describe 'privacy policy page', type: :request do
  describe 'GET /privacy_policy' do
    it 'returns renders successfully' do
      get privacy_policy_index_path
      expect(response).to have_http_status(:ok)
    end

    it 'display contact information' do
      get privacy_policy_index_path
      expect(response.body).to include(I18n.t('privacy_policy.index.what_we_collect.data_we_collect'))
      expect(response.body).to include(I18n.t('privacy_policy.index.why_we_need_your_data.header'))
      expect(response.body).to include(I18n.t('privacy_policy.index.why_we_need_your_data.legal_basis_html'))
    end
  end
end
