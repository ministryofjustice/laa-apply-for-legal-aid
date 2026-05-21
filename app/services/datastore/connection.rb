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

    # The existing token is assumed to already be scoped to the downstream API,
    # so we can use it directly to make requests until it expires,
    # at which point we will use the refresh token to get a new access token scoped to the downstream API
    def datastore_token
      refresh_token! if token_object.expires_at < Time.current
      token_object
    end

    def refresh_token!
      new_token = TokenExchangeService.new(refresh_token: token_object.refresh_token).call
      token_object.store!(credentials: new_token)
    rescue TokenExchangeError => e
      # handle expired refresh token byt bubbling up error. Typically handle by forcing user to sign in again to get a new refresh token with a new expiry time
      # This could be caused by both hitting an expiry time or the refresh token being revoked due to password reset, account disabling/revocation, inactivity,
      # sign frequency policies.
      if e.message.include?"invalid_grant")
        Rails.logger.info("Refresh token expired at #{token_object.expires_at}, you will need to sign in again to get a new refresh token")
        raise ConnectionExpired, "Failed to authenticate with datastore due to expired refresh token!"
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
        "Authorization" => "Bearer #{datastore_token.access_token}",
        "User-Agent" => "CivilApply/#{HostEnv.environment || 'host-env-missing'} Faraday/#{Faraday::VERSION}",
      }
    end
  end
end
