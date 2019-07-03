class ProviderDetailsRetriever
  ApiError = Class.new(StandardError)

  def self.call(username)
    new(username).call
  end

  attr_reader :username

  def initialize(username)
    @username = username
  end

  def call
    provider_details
  end

  private

  def provider_details
    raise_error unless response.is_a?(Net::HTTPOK)

    JSON.parse(response.body, symbolize_names: true)
  end

  def response
    @response ||= Net::HTTP.get_response(URI.parse(url))
  end

  def url
    File.join(base_url, CGI.escape(username))
  end

  def base_url
    return mock_base_url if Rails.configuration.x.provider_details.mock

    Rails.configuration.x.provider_details.url
  end

  def mock_base_url
    "#{Rails.configuration.x.application.host_url}/v1/fake_providers"
  end

  def raise_error
    raise ApiError, "Retrieval Failed: #{response.message} (#{response.code}) #{response.body}"
  end
end
