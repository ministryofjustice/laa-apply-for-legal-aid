require 'rails_helper'

RSpec.describe 'privacy policy page', type: :request do
  describe 'GET /privacy_policy' do
    it 'returns renders successfully' do
      get privacy_policy_index_path
      expect(response).to have_http_status(:ok)
    end

    it 'display contact information' do
      get privacy_policy_index_path
      expect(response.body).to include(I18n.t('privacy_policy.index.more_details.header'))
      expect(response.body).to include(I18n.t('privacy_policy.index.purpose_of_processing.header'))
      expect(response.body).to include(I18n.t('privacy_policy.index.complaints.link_html'))
    end
  end
end
