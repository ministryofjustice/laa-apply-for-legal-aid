require 'rails_helper'

RSpec.describe Citizens::PropertyValuesController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  let(:secure_id) { legal_aid_application.generate_secure_id }
  before { get citizens_legal_aid_application_path(secure_id) }

  describe 'citizen property value test' do
    describe 'GET /citizens/property_value' do
      before { get citizens_property_value_path }

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('How much is your home worth')
      end
    end
  end

  describe 'PATCH /citizens/property_value', type: :request do
    before { patch citizens_property_value_path, params: params }

    context 'when a property value is entered' do
      let(:params) { { legal_aid_application: { property_value: 123_456.78 } } }

      context 'home is owned outright' do
        let(:legal_aid_application) { create :legal_aid_application, :with_applicant, own_home: 'owned_outright' }

        it 'redirects to Shared ownership page' do
          expect(response).to redirect_to(citizens_shared_ownership_path)
        end
      end

      context 'home is owned with a mortgage' do
        let(:legal_aid_application) { create :legal_aid_application, :with_applicant, own_home: 'mortgage' }

        it 'redirects to Outstanding mortgage page' do
          expect(response).to redirect_to(citizens_outstanding_mortgage_path)
        end
      end

      it 'records the value in the legal aid application table' do
        legal_aid_application.reload
        expect(legal_aid_application.property_value).to be_within(0.01).of(123_456.78)
        expect(legal_aid_application.updated_at.utc.to_i).to be_within(1).of(Time.now.to_i)
      end
    end

    context 'when a property value is not entered' do
      let(:params) { { legal_aid_application: { property_value: '' } } }

      it 'shows an error message' do
        expect(response.body).to include('govuk-error-summary__title')
      end

      it 'does not record the value in the legal aid application table' do
        legal_aid_application.reload
        expect(legal_aid_application.property_value).to be nil
      end
    end
  end
end
