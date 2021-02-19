require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe 'FeedbacksController', type: :request do
  describe 'POST /feedback' do
    let(:params) { { feedback: attributes_for(:feedback) } }
    let(:feedback) { Feedback.order(created_at: :asc).last }
    let(:feedback_params) { params[:feedback] }
    let(:provider) { create :provider }
    let(:session_vars) do
      {
        'page_history_id' => page_history_id
      }
    end
    let(:address_lookup_page) { "http://localhost:3000/providers/applications/#{application.id}/address_lookup" }
    let(:additional_accounts_page) { 'http://localhost:3000/citizens/additional_accounts' }
    let(:originating_page) { 'page_outside_apply_service' }
    let(:provider) { create :provider }
    let(:application) { create :application, provider: provider }
    let(:page_history_id) { SecureRandom.uuid }
    let(:page_history) { [address_lookup_page, '/feedback'] }

    before do
      page_history_stub = double(PageHistoryService, read: page_history.to_json)
      allow(PageHistoryService).to receive(:new).with(page_history_id: page_history_id).and_return(page_history_stub)

      set_session(session_vars)
    end

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

        before { sign_in provider }

        it 'adds provider-specific data to feedback record' do
          subject
          expect(feedback.source).to eq 'Provider'
          expect(feedback.email).to eq provider.email
          expect(feedback.originating_page).to eq URI(address_lookup_page).path.split('/').last
        end

        context 'gives feedback during application' do
          let(:page_history) do
            [originating_page, '/feedback/new']
          end

          it 'adds provider-specific data to feedback record' do
            subject
            expect(feedback.source).to eq 'Provider'
            expect(feedback.email).to eq provider.email
            expect(feedback.originating_page).to eq URI(address_lookup_page).path.split('/').last
          end
        end

        context 'gives feedback outside of an application' do
          let(:page_history) do
            ['/feedback/new']
          end

          it 'schedules an email without an application id' do
            expect { subject }.to change { ScheduledMailing.count }.by(1)
            rec = ScheduledMailing.first

            expect(rec.mailer_klass).to eq 'FeedbackMailer'
            expect(rec.mailer_method).to eq 'notify'
            expect(rec.legal_aid_application_id).to be_nil
            expect(rec.addressee).to eq Rails.configuration.x.support_email_address
            expect(rec.arguments).to eq [feedback.id, nil]
            expect(rec.scheduled_at).to have_been_in_the_past
          end

          it 'adds provider-specific data to feedback record' do
            subject
            expect(feedback.source).to eq 'Provider'
            expect(feedback.email).to eq provider.email
            expect(feedback.originating_page).to eq URI(address_lookup_page).path.split('/').last
          end
        end
      end

      context 'as a provider after logging out' do
        let(:originating_page) { address_lookup_page }
        let(:params) { { feedback: attributes_for(:feedback), signed_out: true } }
        it 'adds signed-out provider specific attributes' do
          subject
          expect(feedback.source).to eq 'Provider'
          expect(feedback.email).to eq provider.email
          expect(feedback.originating_page).to eq '/providers/sign_out?locale=en'
        end
      end

      context 'as an applicant' do
        let(:originating_page) { additional_accounts_page }
        let(:session_vars) do
          {
            'current_application_id' => application.id
          }
        end
        it 'adds applicant specific data' do
          subject
          expect(feedback.source).to eq 'Applicant'
          expect(feedback.email).to eq provider.email
          expect(feedback.originating_page).to eq URI(additional_accounts_page).path.split('/').last
        end
      end
    end

    it 'gathers browser data' do
      subject
      expect(feedback.browser).not_to be_empty
      expect(feedback.os).not_to be_empty
      expect(feedback.source).to eq('Unknown')
    end

    context 'provider feedback' do
      let(:originating_page) { address_lookup_page }
      it 'contains provider email' do
        subject
        expect(feedback.source).to eq 'Provider'
        expect(feedback.email).to eq provider.email
      end
    end

    context 'provider feedback' do
      let(:originating_page) { additional_accounts_page }
      let(:session_vars) { { current_application_id: application.id } }
      context 'no appliction id in the page history' do
        it 'contains provider email' do
          subject
          expect(feedback.source).to eq 'Applicant'
          expect(feedback.email).to eq provider.email
        end
      end
    end

    it 'schedules an email' do
      expect { subject }.to change { ScheduledMailing.count }.by(1)
      rec = ScheduledMailing.first

      expect(rec.mailer_klass).to eq 'FeedbackMailer'
      expect(rec.mailer_method).to eq 'notify'
      expect(rec.legal_aid_application_id).to eq application.id
      expect(rec.addressee).to eq Rails.configuration.x.support_email_address
      expect(rec.arguments).to eq [feedback.id, application.id]
      expect(rec.scheduled_at < Time.zone.now).to be true
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

    context 'has come here as applicant or signed in provider' do
      let(:session_vars) { {} }
      it 'hash a hidden form field with no value' do
        expect(response.body).to include('<input type="hidden" name="signed_out" id="signed_out" />')
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
