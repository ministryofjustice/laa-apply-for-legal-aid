module Datastore
  class Connection
    extend Forwardable

    attr_reader :connection

    def_delegators :connection, :post

    def initialize
      @connection = Faraday.new(url:, headers:)
    end

  private

    def url
      Rails.configuration.x.data_access_api.url
    end

    def headers
      {
        "Content-Type" => "application/json",
        "Accept" => "application/json",
        # "X-Authorization" => Rails.configuration.x.data_access_api.auth_key, TBC
        "User-Agent" => "CivilApply/#{HostEnv.environment || 'host-env-missing'} Faraday/#{Faraday::VERSION}",
      }
    end
  end
end
