require 'rails_helper'

RSpec.describe 'citizen additional accounts request test', type: :request do
  describe 'GET /citizens/additional_accounts' do
    before { get citizens_additional_accounts_path }

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
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

      xit 'redirects to the next step in Citizen jouney' do
        # TODO: - set redirect path when known
        expect(response).to redirect_to(:some_path)
      end

      it 'displays holding page' do
        # TODO: Delete when redirect set
        expect(response).to have_http_status(:ok)
        expect(response.body).to match('Landing page')
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
    let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
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
      let(:params) { { has_offline_accounts: 'yes' } }

      xit 'redirects to back to the True Layer steps' do
        # TODO: - set redirect path when known
        expect(response).to redirect_to(:some_path)
      end

      it 'displays holding page' do
        # TODO: Delete when redirect set
        expect(response).to have_http_status(:ok)
        expect(response.body).to match('Landing page')
      end

      it 'does not record choice on legal_aid_application' do
        expect(legal_aid_application.reload).not_to be_has_offline_accounts
      end
    end

    context 'with No submitted' do
      let(:params) { { has_offline_accounts: 'no' } }

      it 'redirects to the next step in Citizen jouney' do
        expect(response).to redirect_to(citizens_own_home_path)
      end

      it 'records choice on legal_aid_application' do
        expect(legal_aid_application.reload).to be_has_offline_accounts
      end
    end
  end
end
