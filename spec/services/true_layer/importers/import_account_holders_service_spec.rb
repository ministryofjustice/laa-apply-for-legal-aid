require "rails_helper"

RSpec.describe TrueLayer::Importers::ImportAccountHoldersService do
  let(:bank_provider) { create(:bank_provider) }
  let(:api_client) { TrueLayer::ApiClient.new(SecureRandom.hex) }

  describe "#call" do
    subject(:call) { described_class.call(api_client, bank_provider) }

    let(:mock_account_holder1) { TrueLayerHelpers::MOCK_DATA[:account_holders][0] }
    let(:mock_account_holder2) { TrueLayerHelpers::MOCK_DATA[:account_holders][1] }
    let(:bank_account_holder1) { bank_provider.bank_account_holders.find_by(full_name: mock_account_holder1[:full_name]) }
    let(:bank_account_holder2) { bank_provider.bank_account_holders.find_by(full_name: mock_account_holder2[:full_name]) }
    let!(:existing_bank_account_holder) { create(:bank_account_holder, bank_provider:) }

    context "when the request is successful" do
      before do
        stub_true_layer_account_holders
      end

      it "adds the bank account holders to the bank_provider" do
        call
        expect(bank_account_holder1.full_name).to eq(mock_account_holder1[:full_name])
        expect(bank_account_holder1.true_layer_response).to eq(mock_account_holder1.deep_stringify_keys)
        expect(bank_account_holder1.addresses).to eq(mock_account_holder1[:addresses].map(&:deep_stringify_keys))
        expect(bank_account_holder1.date_of_birth).to eq(mock_account_holder1[:date_of_birth].to_date)
        expect(bank_account_holder2.full_name).to eq(mock_account_holder2[:full_name])
      end

      it "removes existing bank account holders" do
        call
        expect { existing_bank_account_holder.reload }.to raise_error ActiveRecord::RecordNotFound
      end

      it "is successful" do
        expect(call.success?).to be(true)
      end
    end

    context "when the request is not successful" do
      before do
        stub_true_layer_error
      end

      it "does not change anything" do
        expect { call }.not_to change { bank_provider.bank_account_holders.count }
      end

      it "returns an error" do
        expect(JSON.parse(call.errors.to_json).deep_symbolize_keys.keys.first).to eq(:import_account_holders)
      end
    end
  end
end
