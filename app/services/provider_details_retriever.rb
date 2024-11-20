class ProviderDetailsRetriever
  ApiError = Class.new(StandardError)
  ApiRecordNotFoundError = Class.new(StandardError)

  def self.call(username)
    new(username).call
  end

  attr_reader :username

  def initialize(username)
    @username = username
  end

  def call
    # :nocov:
    Rails.logger.info "**** Using #{self.class} to retrieve Provider Details" unless Rails.env.test?
    # :nocov:
    provider_details
  end

private

  def provider_details
    # :nocov:
    raise_record_not_found_error if response.is_a?(Net::HTTPNotFound)
    # :nocov:

    raise_error unless response.is_a?(Net::HTTPOK)

    JSON.parse(response.body, symbolize_names: true)
  end

  def response
    @response ||= query_api
  end

  def query_api
    @response ||= Net::HTTP.get_response(URI.parse(url))
  rescue StandardError => e
    raise ApiError, "Provider details error: #{e.class} :: #{e.message}"
  end

  def url
    File.join(Rails.configuration.x.provider_details.url, encoded_uri)
  end

  def encoded_uri
    URI.encode_www_form_component(username).gsub("+", "%20")
  end

  def raise_error
    raise ApiError, "Retrieval Failed: #{response.message} (#{response.code}) #{response.body}"
  end

  def raise_record_not_found_error
    # :nocov:
    raise ApiRecordNotFoundError, "Retrieval Failed: #{response.message} (#{response.code}) #{response.body}"
    # :nocov:
  end
end
