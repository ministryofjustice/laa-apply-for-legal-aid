require 'rails_helper'

RSpec.describe TrueLayer::Importers::ImportAccountBalanceService do
  let(:bank_account) { create :bank_account }
  let(:api_client) { TrueLayer::ApiClient.new(bank_account.bank_provider.token) }

  subject { described_class.new(api_client, bank_account) }

  describe '#call' do
    let(:path) { "/data/v1/accounts/#{bank_account.true_layer_id}/balance" }
    let(:endpoint) { TrueLayer::ApiClient::TRUE_LAYER_URL + path }
    let(:result) do
      {
        current: Faker::Number.decimal(2).to_f
      }
    end
    let(:response_body) { { results: [result] }.to_json }

    before do
      stub_request(:get, endpoint).to_return(body: response_body)
    end

    it 'updates the balance of the account' do
      expect { subject.call }.to change { bank_account.balance.to_s }.to(result[:current].to_s)
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

      it 'does not change the balance of the account' do
        expect { subject.call }.not_to change { bank_account.balance }
      end
    end
  end
end
