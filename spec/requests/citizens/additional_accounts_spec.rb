require 'rails_helper'

RSpec.describe 'citizen additional accounts request test', type: :request do
  let(:application) { create :application, :with_applicant, :provider_submitted }
  let(:application_id) { application.id }
  let(:secure_id) { application.generate_secure_id }
  let(:next_flow_step) { flow_forward_path }

  before { get citizens_legal_aid_application_path(secure_id) }

  describe 'GET /citizens/additional_accounts' do
    before { get citizens_additional_accounts_path }

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end
  end

  context 'when an applicant revisits the page to change their answer' do
    before do
      application.update!(has_offline_accounts: true, state: 'use_ccms')
    end

    it 'checks that offline account is reset to nil' do
      get citizens_additional_accounts_path
      expect(application.reload.has_offline_accounts).to be_nil
      expect(application.state).to eq 'provider_submitted'
    end
  end

  describe 'POST /citizens/additional_accounts' do
    let(:params) { {} }
    before { post citizens_additional_accounts_path, params: params }

    it 'does not redirect if no choice submitted' do
      expect(response).to have_http_status(:ok)
    end

    it 'should display an error' do
      expect(response.body).to match('govuk-error-message')
    end

    context 'with Yes submitted' do
      let(:params) { { additional_account: 'yes' } }

      it 'redirects to new action' do
        expect(response).to redirect_to(new_citizens_additional_account_path)
      end
    end

    context 'with No submitted' do
      let(:params) { { additional_account: 'no' } }

      it 'redirects to /citizens/identify_types_of_income(.:format)' do
        expect(response).to redirect_to(citizens_identify_types_of_income_path)
      end
    end
  end

  describe 'GET /citizens/additional_accounts/new' do
    before { get new_citizens_additional_account_path }

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH/PUT /citizens/additional_accounts' do
    let(:params) { {} }
    let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :provider_submitted }
    before do
      get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
      patch(
        citizens_additional_account_path(id: :update),
        params: params
      )
    end

    it 'does not redirect if no choice submitted' do
      expect(response).to have_http_status(:ok)
    end

    it 'should display an error' do
      expect(response.body).to match('govuk-error-message')
    end

    context 'with Yes submitted' do
      let(:params) { { has_online_accounts: 'yes' } }

      it 'redirects to select another bank' do
        expect(response).to redirect_to(citizens_banks_path)
      end

      it 'does not record choice on legal_aid_application' do
        expect(legal_aid_application.reload).not_to be_has_offline_accounts
      end
    end

    context 'with No submitted' do
      let(:params) { { has_online_accounts: 'no' } }

      it 'redirects to contact provider path' do
        expect(response).to redirect_to(citizens_contact_provider_path)
      end

      it 'records choice on legal_aid_application' do
        expect(legal_aid_application.reload).to be_has_offline_accounts
      end
    end
  end
end
