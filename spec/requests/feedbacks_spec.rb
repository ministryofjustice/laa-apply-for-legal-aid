require 'rails_helper'

RSpec.describe 'FeedbacksController', type: :request do
  describe 'POST /feedback' do
    let(:params) { attributes_for(:feedback) }
    let(:feedback) { Feedback.order(created_at: :asc).last }
    subject { post feedback_index_path, params: { feedback: params } }

    it 'create a feedback' do
      expect { subject }.to change { Feedback.count }.by(1)
    end

    it 'applies params to new feedback' do
      subject
      expect(feedback.done_all_needed).to eq(params[:done_all_needed])
      expect(feedback.satisfaction).to eq(params[:satisfaction])
      expect(feedback.improvement_suggestion).to eq(params[:improvement_suggestion])
    end

    it 'gathers browser data' do
      subject
      expect(feedback.browser).not_to be_empty
      expect(feedback.os).not_to be_empty
      expect(feedback.source).to eq('Unknown')
    end

    it 'redirects to show action' do
      subject
      expect(response).to redirect_to(feedback_path(feedback))
    end

    context 'with empty params' do
      let(:params) { { improvement_suggestion: '' } }

      it 'does not create a feedback' do
        expect { subject }.not_to change { Feedback.count }
      end

      it 'renders a page' do
        subject
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /feedback/new' do
    before { get new_feedback_path }

    it 'renders the page' do
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /feedback/:id' do
    let(:feedback) { create :feedback }

    before { get feedback_path(feedback) }

    it 'renders the page' do
      expect(response).to have_http_status(:ok)
    end

    it 'displays a message' do
      expect(unescaped_response_body).to match(I18n.t('feedback.show.title'))
    end
  end
end
