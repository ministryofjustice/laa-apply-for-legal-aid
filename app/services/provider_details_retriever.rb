class ProviderDetailsRetriever
  ApiError = Class.new(StandardError)

  def self.call(username)
    return MockProviderDetailsRetriever.call(username) if Setting.use_mock_provider_details?

    puts 'Using ProviderDetailsRetriever'
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
    File.join(Rails.configuration.x.provider_details.url, CGI.escape(username))
  end

  def raise_error
    raise ApiError, "Retrieval Failed: #{response.message} (#{response.code}) #{response.body}"
  end
end
