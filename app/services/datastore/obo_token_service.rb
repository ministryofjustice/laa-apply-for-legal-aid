# app/services/microsoft_obo_token_service.rb
# If we use/request the downstream API scope at login then the token we receive should just work
# for datastore too. So this service is not required.
#
# Note that this requires
#  1. the data access api registration having an App registration with an Exposed API with a scope defined (e.g. access_as_user) :done:
#  2. the data access api registration's Exposed API having this App listed as an authorized client, to prevent the client app needing
#    to seek consent from the user it is acting on behalf of :done:
#  3. this app is configured to request the downstream API scope in the omniauth configuration :done:
module Datastore
  class OboTokenService
    TOKEN_URL = "https://login.microsoftonline.com/#{ENV.fetch('OMNIAUTH_ENTRAID_TENANT_ID', nil)}/oauth2/v2.0/token".freeze

    def initialize(user_access_token:)
      @user_access_token = user_access_token
    end

    def call
      response = Faraday.post(TOKEN_URL, request_body)
      parsed = JSON.parse(response.body)

      raise("OBO token exchange failed: #{parsed}") unless response.success?

      parsed.fetch("access_token")
    end

  private

    attr_reader :user_access_token

    def request_body
      {
        client_id: ENV.fetch("OMNIAUTH_ENTRAID_CLIENT_ID", nil),
        client_secret: ENV.fetch("OMNIAUTH_ENTRAID_CLIENT_SECRET", nil),
        grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
        requested_token_use: "on_behalf_of",
        assertion: user_access_token,
        scope: ENV.fetch("DATA_ACCESS_API_AUTH_SCOPE", nil),
      }
    end
  end
end
