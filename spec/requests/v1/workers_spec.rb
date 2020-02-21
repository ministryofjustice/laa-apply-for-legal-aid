require 'rails_helper'

RSpec.describe 'GET /v1/workers', type: :request do
  describe 'GET /v1/workers/:worker_id' do
    let(:worker_id) { SecureRandom.hex }
    let(:worker_status) do
      {
        status: 'complete',
        worker: 'ImportBankDataWorker',
        jid: worker_id,
        errors: ['error 1', 'error 2'].to_json
      }.stringify_keys
    end

    subject { get v1_worker_path(id: worker_id) }

    before do
      allow(Sidekiq::Status).to receive(:get_all).with(worker_id).and_return(worker_status)
    end

    it 'returns a successful response with the status and errors of the worker' do
      subject
      expected_json = worker_status.slice('status', 'errors')

      expect(response).to have_http_status(200)
      expect(response.media_type).to eql('application/json')
      expect(response.body).to match_json_expression(expected_json)
    end
  end
end
