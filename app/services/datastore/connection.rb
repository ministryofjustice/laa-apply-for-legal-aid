module Datastore
  class Connection
    extend Forwardable

    class ConnectionError < StandardError; end
    class ConnectionExpired < StandardError; end

    attr_reader :connection, :token_object

    def_delegators :connection, :post

    def initialize(token_object: nil)
      @token_object = token_object
      @connection = Faraday.new(url:, headers:)
    end

  private

    def url
      Rails.configuration.x.data_access_api.url
    end

    def datastore_token_response
      @datastore_token_response ||= TokenService.new(token_object: token_object).call
    rescue TokenExchangeError => e
      if e.response["error"] == "invalid_grant" && token_object.expires_at < Time.current
        Rails.logger.info("Refresh token expired at #{token_object.expires_at}, you will need to sign in again to get a new refresh token")

        raise ConnectionExpired, "Failed to authenticate with datastore due to expired token!"
      else
        Rails.logger.error("Failed to exchange refresh token for datastore bearer token: #{e.message}")

        raise ConnectionError, "Failed to authenticate with datastore: #{e.message}"
      end
    end

    def headers
      {
        "Content-Type" => "application/json",
        "Accept" => "application/json",
        "X-Service-Name" => "CIVIL_APPLY",
        "Authorization" => "Bearer #{datastore_token_response.access_token}",
        "User-Agent" => "CivilApply/#{HostEnv.environment || 'host-env-missing'} Faraday/#{Faraday::VERSION}",
      }
    end
  end
end
