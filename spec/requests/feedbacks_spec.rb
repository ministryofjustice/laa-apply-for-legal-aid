require 'rails_helper'
require 'sidekiq/testing'

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

    it 'sends an email' do
      mailer = double(deliver_later!: true)
      expect(FeedbackMailer).to receive(:notify).and_return(mailer)
      subject
    end

    it 'redirects to show action' do
      subject
      expect(response).to redirect_to(feedback_path(feedback))
    end

    context 'sending the email', :vcr do
      before do
        ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper.clear
        allow_any_instance_of(Notifications::Client).to receive(:get_notification).and_return(OpenStruct.new(status: 'delivered'))
        allow_any_instance_of(DashboardEventHandler).to receive(:call).and_return(double(DashboardEventHandler))
      end

      it 'sends an email with the right parameters' do
        expect_any_instance_of(FeedbackMailer)
          .to receive(:set_personalisation)
          .with(hash_including(improvement_suggestion: params[:improvement_suggestion]))
          .and_call_original
        subject
        ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper.drain
      end
    end

    context 'with empty params' do
      let(:params) { { improvement_suggestion: '' } }

      it 'creates a feedback to record browser data' do
        expect { subject }.to change { Feedback.count }.by(1)
      end

      it 'does not send an email' do
        expect(FeedbackMailer).not_to receive(:notify)
        subject
      end

      it 'renders to show action a page' do
        subject
        expect(response).to redirect_to(feedback_path(feedback))
      end
    end
  end

  describe 'GET /feedback/new' do
    before { get new_feedback_path }

    it 'renders the page' do
      expect(response).to have_http_status(:ok)
    end

    context 'provider signed out' do
      let(:provider) { create :provider }

      before do
        sign_in provider
        delete destroy_provider_session_path
        get new_feedback_path
      end

      it 'displays success message' do
        expect(unescaped_response_body).to match(I18n.t('.feedback.new.signed_out'))
      end

      it 'does not display a back button' do
        expect(unescaped_response_body).not_to match(I18n.t('.generic.back'))
      end
    end
  end

  describe 'GET /feedback/:id' do
    let(:feedback) { create :feedback }
    let(:provider) { create :provider }

    before do
      sign_in provider
      get feedback_path(feedback)
    end

    it 'renders the page' do
      expect(response).to have_http_status(:ok)
    end

    it 'displays a message' do
      expect(unescaped_response_body).to match(I18n.t('feedback.show.title'))
    end

    context 'provider signed out' do
      let(:provider) { create :provider }

      before do
        sign_in provider
        delete destroy_provider_session_path
        get feedback_path(feedback)
      end

      it 'displays close tab message' do
        expect(unescaped_response_body).to match(I18n.t('.feedback.show.close_tab'))
      end
    end
  end
end
