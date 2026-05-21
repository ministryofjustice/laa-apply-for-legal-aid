# Exchanges refresh token acquired at login time for a bear toke scoped with permissions
# to submit to the downstream API, data access API.
#
# Note that this requires
#  1. the data access api registration having an App registration with an Exposed API with a scope defined (e.g. access_as_user) ✅
#  2. the data access api registration's Exposed API having this App listed as an authorized client, to prevent the client app needing
#    to seek consent from the user it is acting on behalf of ✅
#  3. this service requests a new token using the scope defined at 1. above using the refresh token it got at login time ✅
module Datastore
  class TokenExchangeService
    TOKEN_URL = "https://login.microsoftonline.com/#{ENV.fetch('OMNIAUTH_ENTRAID_TENANT_ID', nil)}/oauth2/v2.0/token".freeze

    def initialize(refresh_token:)
      @refresh_token = refresh_token
    end

    def call
      response = Faraday.post(TOKEN_URL, token_request_body)
      parsed_response = JSON.parse(response.body)

      raise(TokenExchangeError, parsed_response) unless response.success?

      TokenResponse.new(parsed_response)
    end

  private

    attr_reader :refresh_token

    def token_request_body
      {
        client_id: ENV.fetch("OMNIAUTH_ENTRAID_CLIENT_ID", nil),
        client_secret: ENV.fetch("OMNIAUTH_ENTRAID_CLIENT_SECRET", nil),
        grant_type: "refresh_token", # we are using the refresh token we got at login to get a new access token for the downstream API, datastore, which is the recommended OBO flow to call downstream APIs on behalf of a user (https://learn.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-on-behalf-of-flow#daemon-applications---no-user-involved)
        refresh_token: refresh_token,
        scope: ENV.fetch("DATA_ACCESS_API_AUTH_SCOPE", nil),
      }
    end
  end
end
