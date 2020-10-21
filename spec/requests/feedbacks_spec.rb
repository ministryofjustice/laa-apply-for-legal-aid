require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe 'FeedbacksController', type: :request do
  describe 'POST /feedback' do
    let(:params) { { feedback: attributes_for(:feedback) } }
    let(:feedback) { Feedback.order(created_at: :asc).last }
    let(:feedback_params) { params[:feedback] }
    let(:provider) { create :provider }
    let(:session_vars) { {} }
    let(:address_lookup_page) { 'http://localhost:3000/providers/applications/fa580023-5b07-493d-bb64-49b6d97c2a97/address_lookup' }
    let(:additional_accounts_page) { 'http://localhost:3000/citizens/additional_accounts' }
    let(:originating_page) { 'page_outside_apply_service' }

    before { set_session(session_vars) }

    subject { post feedback_index_path, params: params, headers: { 'HTTP_REFERER' => originating_page } }

    describe 'creation of feedback record' do
      context 'any type of user' do
        it 'create a feedback' do
          expect { subject }.to change { Feedback.count }.by(1)
        end

        it 'applies params to new feedback' do
          subject
          expect(feedback.done_all_needed).to eq(feedback_params[:done_all_needed])
          expect(feedback.satisfaction).to eq(feedback_params[:satisfaction])
          expect(feedback.difficulty).to eq(feedback_params[:difficulty])
          expect(feedback.improvement_suggestion).to eq(feedback_params[:improvement_suggestion])
        end
      end
      context 'as a logged in provider' do
        let(:originating_page) { address_lookup_page }
        let(:provider_warden_data) { [[provider.id], nil] }
        let(:session_vars) do
          {
            'warden.user.provider.key' => provider_warden_data
          }
        end
        it 'adds provider-specific data to feedback record' do
          subject
          expect(feedback.source).to eq 'provider'
          expect(feedback.email).to eq provider.email
          expect(feedback.originating_page).to eq address_lookup_page
        end
      end

      context 'as a provider after logging out' do
        let(:originating_page) { address_lookup_page }
        let(:params) { { feedback: attributes_for(:feedback), signed_out_provider_id: provider.id } }
        it 'adds signed-out provider specific attributes' do
          subject
          expect(feedback.source).to eq 'provider'
          expect(feedback.email).to eq provider.email
          expect(feedback.originating_page).to eq '/providers/sign_out?locale=en'
        end
      end

      context 'as an applicant' do
        let(:originating_page) { additional_accounts_page }

        it 'adds applicant specific data' do
          subject
          expect(feedback.source).to eq 'citizen'
          expect(feedback.email).to be_nil
          expect(feedback.originating_page).to eq additional_accounts_page
        end
      end
    end

    it 'gathers browser data' do
      subject
      expect(feedback.browser).not_to be_empty
      expect(feedback.os).not_to be_empty
      expect(feedback.source).to eq('unknown')
    end

    it 'sends an email' do
      mailer = double(deliver_later!: true)
      expect(FeedbackMailer).to receive(:notify).and_return(mailer)
      subject
    end

    it 'redirects to show action' do
      subject
      expect(response.body).to include(I18n.t('.feedback.show.title'))
    end

    context 'with no satisfaction params' do
      let(:params) { { feedback: { satisfaction: '' } } }

      it 'does not create a feedback to record browser data' do
        expect { subject }.not_to change { Feedback.count }
      end

      it 'does not send an email' do
        expect(FeedbackMailer).not_to receive(:notify)
        subject
      end

      it 'shows errors on the page' do
        subject
        expect(unescaped_response_body).to include(I18n.t('.activerecord.errors.models.feedback.attributes.satisfaction.blank'))
      end
    end
  end

  describe 'GET /feedback/new' do
    let(:session_vars) { {} }
    before do
      set_session(session_vars)
      get new_feedback_path
    end

    it 'renders the page' do
      expect(response).to have_http_status(:ok)
    end

    it 'displays the provider difficulty question' do
      expect(unescaped_response_body).to match(I18n.t('.feedback.new.difficulty'))
    end

    context 'has come here after provider signing out' do
      let(:session_vars) { { 'signed_out_provider_id' => 'abc-123' } }
      it 'copies the signed_out_provider_id from the session to a hidden form field' do
        expect(response.body).to include('<input type="hidden" name="signed_out_provider_id" id="signed_out_provider_id" value="abc-123" />')
      end
    end

    context 'has come here as applicant or signed in provider' do
      let(:session_vars) { {} }
      it 'hash a hidden form field with no value' do
        expect(response.body).to include('<input type="hidden" name="signed_out_provider_id" id="signed_out_provider_id" />')
      end
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
  end
end
