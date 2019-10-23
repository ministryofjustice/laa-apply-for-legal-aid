require 'rails_helper'

RSpec.describe 'citizen savings and investments', type: :request do
  let(:application) { create :legal_aid_application, :provider_submitted, :with_applicant, :with_savings_amount }
  let(:savings_amount) { application.savings_amount }
  let(:secure_id) { application.generate_secure_id }

  before { get citizens_legal_aid_application_path(secure_id) }

  describe 'GET citizens/savings_and_investment' do
    subject { get citizens_savings_and_investment_path }

    it 'returns http success' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'does not show bank account details' do
      subject
      expect(response.body).not_to match('Account number')
    end

    context 'application has bank details' do
      before do
        bank_provider = create :bank_provider, applicant: application.applicant
        create :bank_account, bank_provider: bank_provider
      end

      it 'shows bank account details' do
        subject
        expect(response.body).to match('Account number')
      end
    end
  end

  describe 'PATCH citizens/savings_and_investment' do
    let(:offline_current_accounts) { rand(1...1_000_000.0).round(2).to_s }
    let(:check_box_offline_current_accounts) { 'true' }
    let(:params) { { savings_amount: { offline_current_accounts: offline_current_accounts, check_box_offline_current_accounts: check_box_offline_current_accounts } } }
    subject { patch citizens_savings_and_investment_path, params: params }

    it 'updates the offline_current_accounts amount' do
      expect { subject }.to change { savings_amount.reload.offline_current_accounts.to_s }.to(offline_current_accounts)
    end

    it 'does not displays an error' do
      subject
      expect(response.body).not_to match('govuk-error-message')
      expect(response.body).not_to match('govuk-form-group--error')
    end

    it 'redirects to the next step in Citizen jouney' do
      subject
      expect(response).to redirect_to(citizens_other_assets_path)
    end

    context 'none of these checkbox is selected' do
      let(:params) { { savings_amount: { none_selected: 'true' } } }

      it 'sets none_selected to true' do
        subject
        expect(savings_amount.reload.none_selected).to eq(true)
      end
    end

    context 'with invalid input' do
      let(:offline_current_accounts) { 'fifty' }

      it 'renders successfully' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'displays an error' do
        subject
        expect(response.body).to match(I18n.t('activemodel.errors.models.savings_amount.attributes.offline_current_accounts.not_a_number'))
        expect(response.body).to match('govuk-error-message')
        expect(response.body).to match('govuk-form-group--error')
      end
    end

    context 'while checking answers' do
      before { application.check_citizen_answers! }

      it 'redirects to the "restrictions" page' do
        subject
        expect(response).to redirect_to(citizens_restrictions_path)
      end
    end
  end
end
