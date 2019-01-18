require 'rails_helper'
RSpec.describe 'citizen percentage share of home', type: :request do
  let(:application) { create :legal_aid_application, :with_applicant }
  let(:secure_id) { application.generate_secure_id }

  before { get citizens_legal_aid_application_path(secure_id) }

  describe 'GET citizens/percentage_home' do
    subject { get citizens_percentage_home_path }

    it 'returns http success' do
      subject
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH citizens/percentage_home' do
    let(:percentage_home) { '33.33' }
    let(:params) { { legal_aid_application: { percentage_home: percentage_home } } }
    subject { patch citizens_percentage_home_path, params: params }

    it 'updates the legal_aid_application' do
      expect { subject }.to change { application.reload.percentage_home.to_s }.to(percentage_home)
    end

    it 'does not displays an error' do
      subject
      expect(response.body).not_to match('govuk-error-message')
      expect(response.body).not_to match('govuk-form-group--error')
    end

    it 'redirects to the next step in Citizen jouney' do
      subject
      expect(response).to redirect_to(citizens_savings_and_investment_path)
    end

    context 'with invalid input' do
      let(:percentage_home) { 'fifty' }

      it 'renders successfully' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'displays an error' do
        subject
        expect(response.body).to match(I18n.t('activemodel.errors.models.legal_aid_application.attributes.percentage_home.not_a_number'))
        expect(response.body).to match('govuk-error-message')
        expect(response.body).to match('govuk-form-group--error')
      end
    end
  end
end
