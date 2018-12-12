require 'rails_helper'

RSpec.describe 'citizen outstanding mortgage request', type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  let(:secure_id) { legal_aid_application.generate_secure_id }

  before do
    get citizens_legal_aid_application_path(secure_id)
    subject
  end

  describe 'GET /citizens/outstanding_mortgage' do
    subject { get citizens_outstanding_mortgage_path }
    it 'renders successfully' do
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /citizens/outstanding_mortgage' do
    let(:amount) { Faker::Number.decimal(4) }
    let(:params) do
      { legal_aid_application: { outstanding_mortgage_amount: amount } }
    end
    subject { patch citizens_outstanding_mortgage_path, params: params }

    xit 'redirects to the next step in Citizen jouney' do
      # TODO: - set redirect path when known
      expect(response).to redirect_to(:some_path)
    end

    it 'displays holding page' do
      # TODO: Delete when redirect set
      expect(response).to have_http_status(:ok)
      expect(response.body).to match('Landing page')
    end

    it 'updates the legal_aid_application' do
      expect(legal_aid_application.reload.outstanding_mortgage_amount).to eq(amount.to_d)
    end

    it 'does not displays an error' do
      expect(response.body).not_to match('govuk-error-message')
      expect(response.body).not_to match('govuk-form-group--error')
    end

    context 'with invalid input' do
      let(:amount) { 'invalid' }

      it 'renders successfully' do
        expect(response).to have_http_status(:ok)
      end

      it 'displays an error' do
        expect(response.body).to match('govuk-error-message')
        expect(response.body).to match('govuk-form-group--error')
      end
    end
  end
end
