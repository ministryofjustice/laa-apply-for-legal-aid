module TrueLayerHelpers
  MOCK_DATA = {
    provider: {
      credentials_id: SecureRandom.hex,
      provider: {
        display_name: 'Lloyds Bank',
        provider_id: 'lloyds'
      }
    },
    account_holders: [{
      full_name: Faker::Name.name,
      date_of_birth: Faker::Date.backward.to_time.utc.iso8601,
      addresses: [{
        address: Faker::Address.street_address,
        city: Faker::Address.city
      }, {
        address: Faker::Address.street_address,
        city: Faker::Address.city
      }]
    }, {
      full_name: Faker::Name.name
    }],
    accounts: [{
      account_id: SecureRandom.hex,
      display_name: Faker::Bank.name,
      currency: Faker::Currency.code,
      account_number: {
        number: Faker::Number.number(10),
        sort_code: Faker::Number.number(6)
      },
      balance: {
        current: Faker::Number.decimal(2).to_f
      },
      transactions: [{
        transaction_id: SecureRandom.hex
      }, {
        transaction_id: SecureRandom.hex
      }]
    }, {
      account_id: SecureRandom.hex,
      display_name: Faker::Bank.name,
      currency: Faker::Currency.code,
      account_number: {
        number: Faker::Number.number(10),
        sort_code: Faker::Number.number(6)
      },
      balance: {
        current: Faker::Number.decimal(2).to_f
      },
      transactions: [{
        transaction_id: SecureRandom.hex
      }, {
        transaction_id: SecureRandom.hex
      }]
    }]
  }.freeze

  def stub_true_layer
    stub_true_layer_provider
    stub_true_layer_accounts
    stub_true_layer_account_holders
    stub_true_layer_account_balances
    stub_true_layer_transactions
  end

  def stub_true_layer_provider
    result = MOCK_DATA[:provider]
    stub_true_layer_endpoint('/data/v1/me', { results: [result] }.to_json)
  end

  def stub_true_layer_accounts
    results = MOCK_DATA[:accounts]
    stub_true_layer_endpoint('/data/v1/accounts', { results: results }.to_json)
  end

  def stub_true_layer_account_holders
    results = MOCK_DATA[:account_holders]
    stub_true_layer_endpoint('/data/v1/info', { results: results }.to_json)
  end

  def stub_true_layer_account_balances
    MOCK_DATA[:accounts].each do |account|
      result = account[:balance]
      stub_true_layer_endpoint("/data/v1/accounts/#{account[:account_id]}/balance", { results: [result] }.to_json)
    end
  end

  def stub_true_layer_transactions
    MOCK_DATA[:accounts].each do |account|
      results = account[:transactions]
      account_id = account[:account_id]
      stub_true_layer_endpoint(%r{/#{account_id}/transactions}, { results: results }.to_json)
    end
  end

  def stub_true_layer_endpoint(path, response_body)
    endpoint = path.is_a?(Regexp) ? path : TrueLayer::ApiClient::TRUE_LAYER_URL + path
    stub_request(:get, endpoint).to_return(body: response_body)
  end

  def stub_true_layer_error
    response_body = {
      error_description: 'Feature not supported by the provider',
      error: :endpoint_not_supported,
      error_details: {}
    }.to_json

    stub_request(:get, /#{TrueLayer::ApiClient::TRUE_LAYER_URL}/).to_return(body: response_body, status: 501)
  end
end
