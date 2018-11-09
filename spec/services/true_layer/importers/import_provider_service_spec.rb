require 'rails_helper'

RSpec.describe TrueLayer::Importers::ImportProviderService do
  let(:token) { SecureRandom.hex }
  let(:api_client) { TrueLayer::ApiClient.new(token) }
  let(:applicant) { create :applicant }

  subject { described_class.new(api_client, applicant, token) }

  describe '#call' do
    let(:mock_provider) { TrueLayerHelpers::MOCK_DATA[:provider] }
    let(:bank_provider) { applicant.bank_providers.find_by(credentials_id: mock_provider[:credentials_id]) }
    let(:existing_credentials_id) { SecureRandom.hex }
    let!(:existing_provider) { create :bank_provider, applicant: applicant, credentials_id: existing_credentials_id }

    context 'request is successful' do
      before do
        stub_true_layer_provider
      end

      it 'adds the bank provider to the applicant' do
        expect { subject.call }.to change { applicant.bank_providers.count } .by(1)
        expect(bank_provider.true_layer_response).to eq(mock_provider.deep_stringify_keys)
        expect(bank_provider.credentials_id).to eq(mock_provider[:credentials_id])
        expect(bank_provider.token).to eq(token)
        expect(bank_provider.name).to eq(mock_provider[:provider][:display_name])
        expect(bank_provider.true_layer_provider_id).to eq(mock_provider[:provider][:provider_id])
      end

      it 'returns the bank provider' do
        result = subject.call
        expect(result).to eq(bank_provider)
      end

      context 'existing provider has same credentials_id' do
        let(:existing_credentials_id) { mock_provider[:credentials_id] }

        it 'does not create another bank provider' do
          expect { subject.call }.not_to change { applicant.bank_providers.count }
        end

        it 'updates the current bank provider' do
          subject.call
          expect(bank_provider.true_layer_response).to eq(mock_provider.deep_stringify_keys)
          expect(bank_provider.token).to eq(token)
          expect(bank_provider.name).to eq(mock_provider[:provider][:display_name])
          expect(bank_provider.true_layer_provider_id).to eq(mock_provider[:provider][:provider_id])
        end
      end
    end

    context 'request is not successful' do
      before do
        stub_true_layer_error
      end

      it 'returns nil' do
        expect { subject.call }.not_to change { applicant.bank_providers.count }
      end
    end
  end
end
