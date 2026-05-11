module Datastore
  class TokenResponse
    attr_reader :raw_response

    def initialize(raw_response)
      @raw_response = raw_response
    end

    def access_token
      raw_response["access_token"]
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
end
