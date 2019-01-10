require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe ImportBankDataWorker, type: :worker do
  let(:token) { SecureRandom.hex }
  let(:token_expires_at) { 1.hour.from_now.round }
  let(:applicant) { create :applicant }

  subject do
    worker_id = described_class.perform_async(applicant.id, token, token_expires_at)
    described_class.drain
    worker_id
  end

  before { described_class.clear }

  context 'it generates an error' do
    let(:api_error) do
      {
        error_description: 'Feature not supported by the provider',
        error: :endpoint_not_supported,
        error_details: { foo: :bar }
      }
    end
    let(:worker_id) { subject }
    let(:worker_status) { Sidekiq::Status.get_all(worker_id) }
    let(:worker_errors) { JSON.parse(worker_status['errors']) }

    before do
      endpoint = TrueLayer::ApiClient::TRUE_LAYER_URL + '/data/v1/me'
      stub_request(:get, endpoint).to_return(body: api_error.to_json, status: 501)
    end

    it 'saves the error' do
      subject
      expect(worker_errors.to_s).to include(api_error[:error_description])
      expect(worker_errors.to_s).to include(api_error[:error].to_s)
    end
  end
end
