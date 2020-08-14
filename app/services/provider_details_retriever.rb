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
    puts "**** Using #{self.class} to retrieve Provider Details" unless Rails.env.test?
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

  def url # rubocop:disable Lint/UriEscapeUnescape
    File.join(Rails.configuration.x.provider_details.url, encoded_uri)
  end

  def encoded_uri
    URI.encode_www_form_component(username).gsub('+', '%20')
  end

  def raise_error
    raise ApiError, "Retrieval Failed: #{response.message} (#{response.code}) #{response.body}"
  end
end
