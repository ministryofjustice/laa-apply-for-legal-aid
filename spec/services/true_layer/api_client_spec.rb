require "rails_helper"

RSpec.describe TrueLayer::ApiClient do
  subject(:api_client) { described_class.new(token) }

  let(:token) { SecureRandom.hex }

  describe "#provider" do
    let(:mock_provider) { TrueLayerHelpers::MOCK_DATA[:provider] }

    before do
      stub_true_layer_provider
    end

    it "returns the bank provider" do
      expect(api_client.provider.value.first).to eq(mock_provider)
    end

    context "when the result is not json" do
      before do
        endpoint = "#{TrueLayer::ApiClient::TRUE_LAYER_URL}/data/v1/me"
        stub_request(:get, endpoint).to_return(body: "Boom!", status: 501)
      end

      it "returns an error" do
        expect(api_client.provider.error).to be_a(JSON::ParserError)
      end
    end

    context "when the API cannot be reached" do
      before do
        endpoint = "#{TrueLayer::ApiClient::TRUE_LAYER_URL}/data/v1/me"
        stub_request(:get, endpoint).to_timeout
      end

      it "returns an error" do
        expect(api_client.provider.error).to be_a(Faraday::ConnectionFailed)
      end
    end
  end

  describe "#date_params" do
    subject(:date_params) { api_client.date_params(3.months.ago.utc.beginning_of_day, Time.current) }

    it { is_expected.to be_a Hash }

    describe "format" do
      let(:expected) do
        { from: "2023-04-30T00:00:00Z", to: "2023-07-31T07:57:14Z" }
      end

      it "is expected to be a pair of date times from now to minus 3 months" do
        travel_to(Time.zone.local(2023, 7, 31, 8, 57, 14)) do
          expect(date_params).to eq expected
        end
      end
    end
  end
end
