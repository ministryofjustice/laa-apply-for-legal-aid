require "rails_helper"

RSpec.describe TrueLayer::Importers::ImportAccountBalanceService do
  let(:mock_account) { TrueLayerHelpers::MOCK_DATA[:accounts].first }
  let(:mock_result) { mock_account[:balance] }
  let(:bank_account) { create(:bank_account, true_layer_id: mock_account[:account_id]) }
  let(:api_client) { TrueLayer::ApiClient.new(SecureRandom.hex) }

  describe "#call" do
    subject(:call) { described_class.call(api_client, bank_account) }

    context "when a request is successful" do
      before do
        stub_true_layer_account_balances
      end

      it "updates the balance of the account" do
        expect { call }.to change { bank_account.balance.to_s }.to(mock_result[:current].to_s)
      end

      it "is successful" do
        expect(call.success?).to be(true)
      end
    end

    context "when a request is not successful" do
      before do
        stub_true_layer_error
      end

      it "does not change the balance of the account" do
        expect { call }.not_to change(bank_account, :balance)
      end

      it "returns an error" do
        expect(JSON.parse(call.errors.to_json).deep_symbolize_keys.keys.first).to eq(:import_account_balance)
      end
    end
  end
end
