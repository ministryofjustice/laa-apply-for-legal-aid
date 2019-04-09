require 'rails_helper'

RSpec.describe ErrorsController, type: :request do
  describe 'GET /error/page_not_found' do
    subject { get error_path(:page_not_found) }

    before { subject }

    it 'renders successfully' do
      expect(response).to have_http_status(:ok)
    end

    it 'displays the correct header' do
      expect(response.body).to include('Page not found')
    end
  end

  describe 'GET /error/assessment_already_completed' do
    subject { get error_path(:assessment_already_completed) }

    before { subject }

    it 'renders successfully' do
      expect(response).to have_http_status(:ok)
    end

    it 'displays the correct header' do
      expect(response.body).to match(/already completed[\w\s]+financial assessment/)
    end
  end

  describe 'GET /error/link_expired' do
    subject { get error_path(:link_expired) }

    before { subject }

    it 'renders successfully' do
      expect(response).to have_http_status(:ok)
    end

    it 'displays the correct header' do
      expect(response.body).to match('link has expired')
    end
  end
end
