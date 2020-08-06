require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe ImportBankDataWorker, type: :worker do
  let(:token) { SecureRandom.hex }
  let(:token_expires_at) { 1.hour.from_now.round }
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :with_transaction_period }
  let(:applicant) { legal_aid_application.applicant }
  let(:worker_id) { described_class.perform_async(legal_aid_application.id) }

  before do
    described_class.clear
    applicant.store_true_layer_token(token: token, expires: token_expires_at)
    worker_id
    endpoint = "#{TrueLayer::ApiClient::TRUE_LAYER_URL}/data/v1/me"
    stub_request(:get, endpoint).to_return(body: api_error.to_json, status: 501)
    described_class.drain
  end

  context 'it generates an error' do
    let(:api_error) do
      {
        error_description: 'Feature not supported by the provider',
        error: :endpoint_not_supported,
        error_details: { foo: :bar }
      }
    end
    let(:worker_status) { Sidekiq::Status.get_all(worker_id) }
    let(:worker_errors) { JSON.parse(worker_status['errors']) }

    it 'saves the error' do
      subject
      expect(worker_errors.to_s).to include(api_error[:error_description])
      expect(worker_errors.to_s).to include(api_error[:error].to_s)
    end
  end
end
