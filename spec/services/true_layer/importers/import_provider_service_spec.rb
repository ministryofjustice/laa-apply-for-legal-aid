require 'rails_helper'

RSpec.describe TrueLayer::Importers::ImportProviderService do
  let(:token) { SecureRandom.hex }
  let(:api_client) { TrueLayer::ApiClient.new(token) }
  let(:applicant) { create :applicant }

  subject { described_class.new(api_client, applicant, token) }

  describe '#call' do
    let(:path) { '/data/v1/me' }
    let(:endpoint) { TrueLayer::ApiClient::TRUE_LAYER_URL + path }
    let(:bank_name) { Faker::Bank.name }
    let(:credentials_id) { SecureRandom.hex }
    let(:result) do
      {
        credentials_id: credentials_id,
        provider: {
          display_name: bank_name,
          provider_id: bank_name.parameterize
        }
      }
    end
    let(:response_body) { { results: [result] }.to_json }
    let(:existing_credentials_id) { SecureRandom.hex }
    let(:bank_provider) { applicant.bank_providers.find_by(credentials_id: credentials_id) }
    let!(:existing_provider) { create :bank_provider, applicant: applicant, credentials_id: existing_credentials_id }

    before do
      stub_request(:get, endpoint).to_return(body: response_body)
    end

    it 'adds the bank provider to the applicant' do
      expect { subject.call }.to change { applicant.bank_providers.count } .by(1)
      expect(bank_provider.true_layer_response).to eq(result.deep_stringify_keys)
      expect(bank_provider.credentials_id).to eq(credentials_id)
      expect(bank_provider.token).to eq(token)
      expect(bank_provider.name).to eq(bank_name)
      expect(bank_provider.true_layer_provider_id).to eq(bank_name.parameterize)
    end

    it 'returns the bank provider' do
      result = subject.call
      expect(result).to eq(bank_provider)
    end

    context 'existing provider has same credentials_id' do
      let(:existing_credentials_id) { credentials_id }

      it 'does not create another bank provider' do
        expect { subject.call }.not_to change { applicant.bank_providers.count }
      end

      it 'updates the current bank provider' do
        subject.call
        expect(bank_provider.true_layer_response).to eq(result.deep_stringify_keys)
        expect(bank_provider.token).to eq(token)
        expect(bank_provider.name).to eq(bank_name)
        expect(bank_provider.true_layer_provider_id).to eq(bank_name.parameterize)
      end
    end

    context 'request is not successful' do
      let(:response_body) do
        {
          error_description: 'Feature not supported by the provider',
          error: :endpoint_not_supported,
          error_details: {}
        }.to_json
      end

      before do
        stub_request(:get, endpoint).to_return(body: response_body, status: 501)
      end

      it 'returns nil' do
        expect { subject.call }.not_to change { applicant.bank_providers.count }
      end
    end
  end
end
