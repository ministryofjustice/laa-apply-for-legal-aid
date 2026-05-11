module Datastore
  class Connection
    extend Forwardable

    attr_reader :connection, :refresh_token

    def_delegators :connection, :post

    def initialize(refresh_token: nil)
      @refresh_token = refresh_token
      @connection = Faraday.new(url:, headers:)
    end

  private

    def url
      Rails.configuration.x.data_access_api.url
    end

    def datastore_token_response
      @datastore_token_response ||= TokenService.new(refresh_token: refresh_token).call
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
