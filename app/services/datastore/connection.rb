module Datastore
  class Connection
    extend Forwardable

    class ConnectionError < StandardError; end
    class RefreshTokenExpired < StandardError; end

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

    # Use existing access_token to avoid unnecessary network roundtrips, but access tokens that are expired or do not include the required scope
    # must be exchanged for a new one using the refresh token. If the refresh token is expired then a RefreshTokenExpired error is raised, which
    # should be handled by forcing user sign in again
    def datastore_token
      return MockDatastoreToken.new if Rails.configuration.x.omniauth_entraid.mock_auth_enabled && HostEnv.not_production?

      if token_exhange_required?
        TokenExchangeService.new(token_object: token_object).call
      else
        token_object
      end
    rescue Datastore::TokenExchangeError => e
      if e.message.include?("invalid_grant")
        Rails.logger.info("Refresh token expired. Provider will need to sign in again to get a new refresh token")

        raise RefreshTokenExpired, "Failed to authenticate with datastore due to expired refresh token!"
      else
        Rails.logger.error("Failed to exchange refresh token for datastore bearer token: #{e.message}")

        raise ConnectionError, "Failed to authenticate with datastore: #{e.message}"
      end
    rescue StandardError => e
      Rails.logger.error("Unexpected error occurred while authenticating with datastore: #{e.message}")
      raise ConnectionError, "Unexpected error occurred while authenticating with datastore: #{e.message}"
    end

    def token_exhange_required?
      token_object.scope.exclude?(Rails.configuration.x.data_access_api.auth_scope) || token_object.access_token_expires_at < Time.current
    end

    def headers
      {
        "Content-Type" => "application/json",
        "Accept" => "application/json",
        "X-Service-Name" => "CIVIL_APPLY",
        "Authorization" => "Bearer #{datastore_token.access_token}",
        "User-Agent" => "CivilApply/#{HostEnv.environment || 'host-env-missing'} Faraday/#{Faraday::VERSION}",
      }
    end
  end
end
