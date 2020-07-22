require 'rails_helper'

RSpec.describe 'AuthController', type: :request do
  let(:params) do
    {
      'message' => 'provider_error',
      'origin' => origin_path,
      'strategy' => 'true_layer'
    }
  end
  describe 'GET failure' do
    subject { get '/auth/failure', params: params }

    context 'origin from citizens/banks' do
      let(:origin_path) { citizens_banks_path }
      it 'redirects to citizens_consent_path' do
        subject
        expect(response).to redirect_to citizens_consent_path(auth_failure: true)
      end
    end

    context 'origin from elsewhere' do
      let(:origin_path) { root_path }
      it 'redirects to access denied' do
        subject
        expect(response).to redirect_to error_path(:access_denied)
      end
    end

    context 'no origin' do
      it 'redirects to access denied' do
        get '/auth/failure'
        expect(response).to redirect_to error_path(:access_denied)
      end
    end
  end
end
