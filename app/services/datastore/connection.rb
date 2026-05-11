module Datastore
  class Connection
    extend Forwardable

    attr_reader :connection
    attr_accessor :access_token

    def_delegators :connection, :post

    def initialize(access_token: nil)
      @access_token = access_token
      @connection = Faraday.new(url:, headers:)
    end

  private

    def url
      Rails.configuration.x.data_access_api.url
    end

    # def obo_access_token
    #   @obo_access_token ||= OboTokenService.new(user_access_token: access_token).call
    # end

    def headers
      {
        "Content-Type" => "application/json",
        "Accept" => "application/json",
        "X-Service-Name" => "CIVIL_APPLY",
        "Authorization" => "Bearer #{access_token}",
        "User-Agent" => "CivilApply/#{HostEnv.environment || 'host-env-missing'} Faraday/#{Faraday::VERSION}",
      }
    end
  end
end
