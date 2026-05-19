# Exchanges refresh token acquired at login time for a bear toke scoped with permissions
# to submit to the downstream API, data access API.
#
# Note that this requires
#  1. the data access api registration having an App registration with an Exposed API with a scope defined (e.g. access_as_user) ✅
#  2. the data access api registration's Exposed API having this App listed as an authorized client, to prevent the client app needing
#    to seek consent from the user it is acting on behalf of ✅
#  3. this service requests a new token using the scope defined a 1. above using the refresh token it got at login time ✅
module Datastore
  class TokenService
    TOKEN_URL = "https://login.microsoftonline.com/#{ENV.fetch('OMNIAUTH_ENTRAID_TENANT_ID', nil)}/oauth2/v2.0/token".freeze

    def initialize(access_token:)
      @access_token = access_token
    end

    def call
      response = Faraday.post(TOKEN_URL, token_request_body)
      parsed_response = JSON.parse(response.body)

      raise(TokenExchangeError, parsed_response) unless response.success?

      TokenResponse.new(parsed_response)
    end

  private

    attr_reader :access_token

    def token_request_body
      {
        client_id: ENV.fetch("OMNIAUTH_ENTRAID_CLIENT_ID", nil),
        client_secret: ENV.fetch("OMNIAUTH_ENTRAID_CLIENT_SECRET", nil),
        grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer", # OBO flow grant type
        requested_token_use: "on_behalf_of",
        assertion: access_token,
        scope: ENV.fetch("DATA_ACCESS_API_AUTH_SCOPE", nil),
      }
    end
  end

  class TokenResponse
    attr_reader :raw_response

    def initialize(raw_response)
      @raw_response = raw_response
    end

    def access_token
      raw_response.fetch("access_token")
    end

    def refresh_token
      raw_response["refresh_token"]
    end

    def expires_in
      raw_response["expires_in"]
    end

    def id_token
      raw_response["id_token"]
    end

    def scope
      raw_response["scope"]
    end
  end

  class TokenExchangeError < StandardError
    attr_reader :response

    def initialize(response)
      @response = response

      super(
        [
          "Microsoft token exchange failed",
          response["error"],
          response["error_description"],
        ].compact.join(": ")
      )
    end
  end
end
