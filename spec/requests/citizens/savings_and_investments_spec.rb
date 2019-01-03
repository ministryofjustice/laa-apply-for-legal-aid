require 'rails_helper'

RSpec.describe 'citizen savings and investments', type: :request do
  let(:application) { create :legal_aid_application, :with_applicant, :with_savings_amount }
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
    let(:isa) { Faker::Number.decimal.to_s }
    let(:check_box_isa) { 'true' }
    let(:params) { { savings_amount: { isa: isa, check_box_isa: check_box_isa } } }
    subject { patch citizens_savings_and_investment_path, params: params }

    it 'updates the isa amount' do
      expect { subject }.to change { savings_amount.reload.isa.to_s }.to(isa)
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

    context 'with invalid input' do
      let(:isa) { 'fifty' }

      it 'renders successfully' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'displays an error' do
        subject
        expect(response.body).to match(I18n.t('activemodel.errors.models.savings_amount.attributes.isa.not_a_number'))
        expect(response.body).to match('govuk-error-message')
        expect(response.body).to match('govuk-form-group--error')
      end
    end
  end
end
