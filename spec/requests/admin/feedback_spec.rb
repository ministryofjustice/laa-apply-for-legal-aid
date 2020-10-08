require 'rails_helper'

RSpec.describe Admin::FeedbackController, type: :request do
  let(:count) { 2 }
  let(:admin_user) { create :admin_user }
  let(:params) { {} }

  before do
    create :feedback, satisfaction: 'satisfied'
    create_list :feedback, count
    sign_in admin_user
  end

  describe 'GET /admin/feedback' do
    subject { get admin_feedback_path(params) }

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'displays title' do
      subject
      expect(response.body).to include(I18n.t('admin.feedback.show.heading_1'))
    end

    it 'displays feedback' do
      subject
      Feedback.all.each do |feedback|
        expect(response.body).to include(feedback.improvement_suggestion)
      end
    end

    context 'with pagination' do
      it 'shows current total information' do
        subject
        expect(response.body).to include('Showing 3 of 3')
      end

      it 'does not show navigation links' do
        subject
        expect(parsed_response_body.css('.pagination-container nav')).to be_empty
      end

      context 'and more applications than page size' do
        let(:params) { { page_size: 3 } }
        let(:count) { 4 }

        it 'show page information' do
          subject
          expect(response.body).to include('Showing 1 - 3 of 5 results')
        end

        it 'shows pagination' do
          subject
          expect(parsed_response_body.css('.pagination-container nav').text).to match(/Previous\s+1\s+2\s+Next/)
        end
      end
    end

    context 'when not authenticated' do
      before { sign_out admin_user }

      it 'redirects to log in' do
        subject
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end
  end
end
