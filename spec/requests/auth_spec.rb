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
  end
end
