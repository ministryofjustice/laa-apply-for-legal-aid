module TrueLayerHelpers
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

    # the /o suffix to the regex ensures the regex gets cached and not run each time the
    # regex is called.  It is enforced by Performance/ConstantRegexp
    stub_request(:get, /#{TrueLayer::ApiClient::TRUE_LAYER_URL}/o).to_return(body: response_body, status: 501)
  end
end
