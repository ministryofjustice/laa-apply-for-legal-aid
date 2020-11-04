require 'rails_helper'

RSpec.describe ErrorsController, type: :request do
  describe 'actions that result in error pages being shown' do
    describe 'unknown page' do
      context 'default locale' do
        before { get '/unknown/path' }
        it 'redirect to page not found' do
          expect(response).to redirect_to('/error/page_not_found?locale=en')
        end
      end

      context 'Welsh locale' do
        before { get '/unknown/path', params: { locale: 'cy' } }
        after { I18n.locale = I18n.default_locale }
        it 'redirect to page not found' do
          expect(response).to redirect_to('/error/page_not_found?locale=cy')
        end
      end
    end

    describe 'object not found' do
      context 'default locale' do
        before { get feedback_path(SecureRandom.uuid) }
        it 'redirect to page not found' do
          expect(response).to redirect_to('/error/page_not_found?locale=en')
        end
      end

      context 'Welsh locale' do
        before { get feedback_path(SecureRandom.uuid, locale: :cy) }
        after { I18n.locale = I18n.default_locale }
        it 'redirect to page not found' do
          expect(response).to redirect_to('/error/page_not_found?locale=cy')
        end
      end
    end
  end

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

  describe 'GET /error/access_denied' do
    subject { get error_path(:access_denied) }

    before { subject }

    it 'renders successfully' do
      expect(response).to have_http_status(:ok)
    end

    it 'displays the correct header' do
      expect(response.body).to match(/Access denied/)
    end
  end
end
