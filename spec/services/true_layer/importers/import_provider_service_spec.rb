require 'rails_helper'

RSpec.describe TrueLayer::Importers::ImportProviderService do
  let(:token) { SecureRandom.hex }
  let(:token_expires_at) { Time.current + 1.hour }
  let(:api_client) { TrueLayer::ApiClient.new(token) }
  let(:applicant) { create :applicant, :with_true_layer_tokens }

  describe '#call' do
    let(:mock_provider) { TrueLayerHelpers::MOCK_DATA[:provider] }
    let(:bank_provider) { applicant.bank_providers.find_by(true_layer_provider_id: mock_provider[:provider][:provider_id]) }
    let(:existing_true_layer_provider_id) { SecureRandom.hex }
    let!(:existing_provider) { create :bank_provider, applicant: applicant, true_layer_provider_id: existing_true_layer_provider_id }

    subject { described_class.call(api_client: api_client, applicant: applicant, token_expires_at: token_expires_at) }

    context 'request is successful' do
      before do
        stub_true_layer_provider
      end

      it 'adds the bank provider to the applicant' do
        expect { subject }.to change { applicant.bank_providers.count }.by(1)
        expect(bank_provider.true_layer_response).to eq(mock_provider.deep_stringify_keys)
        expect(bank_provider.credentials_id).to eq(mock_provider[:credentials_id])
        expect(bank_provider.token).to eq(applicant.true_layer_secure_data_id)
        expect(bank_provider.token_expires_at.utc.to_s).to eq(token_expires_at.utc.to_s)
        expect(bank_provider.name).to eq(mock_provider[:provider][:display_name])
        expect(bank_provider.true_layer_provider_id).to eq(mock_provider[:provider][:provider_id])
      end

      it 'returns the bank provider' do
        command = subject
        expect(command.result).to eq(bank_provider)
      end

      context 'existing provider has same true_layer_provider_id' do
        let(:existing_true_layer_provider_id) { mock_provider[:provider][:provider_id] }

        it 'does not create another bank provider' do
          expect { subject }.not_to change { applicant.bank_providers.count }
        end

        it 'updates the current bank provider' do
          subject
          expect(bank_provider.true_layer_response).to eq(mock_provider.deep_stringify_keys)
          expect(bank_provider.token).to eq(applicant.true_layer_secure_data_id)
          expect(bank_provider.name).to eq(mock_provider[:provider][:display_name])
          expect(bank_provider.true_layer_provider_id).to eq(mock_provider[:provider][:provider_id])
        end
      end

      it 'is successful' do
        expect(subject.success?).to eq(true)
      end
    end

    context 'request is not successful' do
      before do
        stub_true_layer_error
      end

      it 'returns nil' do
        expect { subject }.not_to change { applicant.bank_providers.count }
      end

      it 'returns an error' do
        expect(subject.errors.keys.first).to eq(:import_provider)
      end
    end
  end
end
