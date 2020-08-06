require 'rails_helper'

RSpec.describe TrueLayer::ApiClient do
  let(:token) { SecureRandom.hex }

  subject { described_class.new(token) }

  describe '#provider' do
    let(:mock_provider) { TrueLayerHelpers::MOCK_DATA[:provider] }

    before do
      stub_true_layer_provider
    end

    it 'returns the bank provider' do
      expect(subject.provider.value.first).to eq(mock_provider)
    end

    context 'result is not json' do
      before do
        endpoint = "#{TrueLayer::ApiClient::TRUE_LAYER_URL}/data/v1/me"
        stub_request(:get, endpoint).to_return(body: 'Boom!', status: 501)
      end

      it 'returns an error' do
        expect(subject.provider.error).to be_a(JSON::ParserError)
      end
    end

    context 'API cannot be reached' do
      before do
        endpoint = "#{TrueLayer::ApiClient::TRUE_LAYER_URL}/data/v1/me"
        stub_request(:get, endpoint).to_timeout
      end

      it 'returns an error' do
        expect(subject.provider.error).to be_a(Faraday::ConnectionFailed)
      end
    end
  end
end
