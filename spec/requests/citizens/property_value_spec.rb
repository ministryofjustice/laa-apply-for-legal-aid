require 'rails_helper'

RSpec.describe Citizens::PropertyValuesController, type: :request do
  describe 'citizen property value test' do
    describe 'GET /citizens/property_value' do
      before { get citizens_property_value_path }

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
        expect(unescaped_response_body).to include('How much is your home worth')
      end
    end
  end

  describe 'PATCH /citizens/property_value', type: :request do
    let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
    before do
      sign_in legal_aid_application.applicant
      patch citizens_property_value_path, params: params
    end

    context 'when a property value is entered' do
      let(:params) { { legal_aid_application: { property_value: 123_456.78 } } }

      xit 'redirects to new action' do
        expect(response.body).to include('Navigate to')
        # TO DO
        # expect(response).to redirect_to(to_be_determined_path)
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
        expect(unescaped_response_body).to include('There is a problem')
      end

      it 'does not record the value in the legal aid application table' do
        legal_aid_application.reload
        expect(legal_aid_application.property_value).to be nil
      end
    end
  end
end
