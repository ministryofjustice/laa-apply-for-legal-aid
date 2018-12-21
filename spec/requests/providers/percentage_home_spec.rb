require 'rails_helper'
RSpec.describe 'provider percentage share of home test', type: :request do
  let!(:application) { create :legal_aid_application, :with_applicant }

  describe 'GET #/providers/applications/:legal_aid_application_id/percentage_home' do
    subject { get providers_legal_aid_application_percentage_home_path(application) }

    it 'returns http success' do
      subject
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH #/providers/applications/:legal_aid_application_id/percentage_home' do
    let(:percentage_home) { '33.33' }
    let(:params) { { legal_aid_application: { percentage_home: percentage_home } } }
    subject { patch providers_legal_aid_application_percentage_home_path(application), params: params }

    it 'updates the legal_aid_application' do
      expect { subject }.to change { application.reload.percentage_home.to_s }.to(percentage_home)
    end

    it 'does not displays an error' do
      subject
      expect(response.body).not_to match('govuk-error-message')
      expect(response.body).not_to match('govuk-form-group--error')
    end

    xit 'redirects to the next step in Provider jouney' do
      # TODO: - set redirect path when known
      subject
      expect(response).to redirect_to(:providers_legal_aid_application_savings_and_investment_path)
    end

    it 'displays holding page' do
      # TODO: Delete when redirect set
      subject
      expect(response).to have_http_status(:ok)
      expect(response.body).to match('Navigate to question 2a. Do you have any savings or investments?')
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
