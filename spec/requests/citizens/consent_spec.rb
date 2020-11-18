require 'rails_helper'

RSpec.describe Citizens::ConsentsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :with_non_passported_state_machine, :applicant_entering_means }
  describe 'GET /citizens/consent' do
    before do
      get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
      get citizens_consent_path
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
      expect(unescaped_response_body).to include('Do you agree to share 3 months of bank statements with ' \
                                                 "the <abbr title='Legal Aid Agency'>LAA</abbr> via TrueLayer?")
    end
  end

  describe 'PATCH /citizens/consent', type: :request do
    before do
      get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
      patch citizens_consent_path, params: params
    end

    context 'when consent is granted' do
      let(:params) { { legal_aid_application: { open_banking_consent: 'true' } } }

      it 'redirects to new action' do
        expect(response).to redirect_to(citizens_banks_path)
      end

      it 'records the decision on the legal aid application' do
        legal_aid_application.reload
        expect(legal_aid_application.open_banking_consent).to eq(true)
        expect(legal_aid_application.open_banking_consent_choice_at.to_s(be_between(2.seconds.ago, 1.second.from_now)))
      end

      it 'updates application state' do
        expect(legal_aid_application.reload.applicant_entering_means?).to eq(true)
      end
    end

    context 'when consent is not granted' do
      let(:params) { { legal_aid_application: { open_banking_consent: 'false' } } }

      it 'redirects to a holding page action' do
        expect(response).to redirect_to(citizens_contact_provider_path)
      end

      it 'records the decision on the legal aid application' do
        legal_aid_application.reload
        expect(legal_aid_application.open_banking_consent).to eq(false)
        expect(legal_aid_application.open_banking_consent_choice_at.to_s(be_between(2.seconds.ago, 1.second.from_now)))
      end

      it 'updates application state' do
        expect(legal_aid_application.reload.use_ccms?).to eq(true)
      end
    end

    context 'no values given' do
      let(:params) { { legal_aid_application: { open_banking_consent: nil } } }

      it 'returns an error' do
        expect(unescaped_response_body).to include(I18n.t('activemodel.errors.models.legal_aid_application.attributes.open_banking_consents.citizens.blank_html'))
      end
    end
  end
end
