require 'rails_helper'

RSpec.describe TrueLayer::Importers::ImportAccountHoldersService do
  let(:bank_provider) { create :bank_provider }
  let(:api_client) { TrueLayer::ApiClient.new(bank_provider.token) }

  subject { described_class.new(api_client, bank_provider) }

  describe '#call' do
    let(:path) { '/data/v1/info' }
    let(:endpoint) { TrueLayer::ApiClient::TRUE_LAYER_URL + path }
    let(:result_1) do
      {
        full_name: Faker::Name.name,
        date_of_birth: Faker::Date.backward.to_time.utc.iso8601,
        addresses: [
          {
            address: Faker::Address.street_address,
            city: Faker::Address.city
          },
          {
            address: Faker::Address.street_address,
            city: Faker::Address.city
          }
        ]
      }
    end
    let(:result_2) { { full_name: Faker::Name.name } }
    let(:results) { [result_1, result_2] }
    let(:response_body) { { results: results }.to_json }
    let(:bank_account_holder_1) { bank_provider.bank_account_holders.find_by(full_name: result_1[:full_name]) }
    let(:bank_account_holder_2) { bank_provider.bank_account_holders.find_by(full_name: result_2[:full_name]) }
    let!(:existing_bank_account_holder) { create :bank_account_holder, bank_provider: bank_provider }

    before do
      stub_request(:get, endpoint).to_return(body: response_body)
    end

    it 'adds the bank account holders to the bank_provider' do
      subject.call
      expect(bank_account_holder_1.full_name).to eq(result_1[:full_name])
      expect(bank_account_holder_1.true_layer_response).to eq(result_1.deep_stringify_keys)
      expected_full_address = result_1[:addresses]&.map do |address|
                                address.values.join(', ')
                              end&.join('; ')
      expect(bank_account_holder_1.full_address).to eq(expected_full_address)
      expect(bank_account_holder_1.date_of_birth).to eq(result_1[:date_of_birth].to_date)
      expect(bank_account_holder_2.full_name).to eq(result_2[:full_name])
    end

    it 'removes existing bank account holders' do
      subject.call
      expect { existing_bank_account_holder.reload }.to raise_error ActiveRecord::RecordNotFound
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

      it 'leaves the list of bank account holders empty' do
        expect { subject.call }.to change { bank_provider.bank_account_holders.count }.to(0)
      end
    end
  end
end
