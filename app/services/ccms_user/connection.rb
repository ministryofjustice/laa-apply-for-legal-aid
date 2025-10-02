module CCMSUser
  class Connection
    extend Forwardable

    attr_reader :conn

    def_delegators :conn, :get

    def initialize
      @conn = Faraday.new(url:, headers:)
    end

  private

    def url
      Rails.configuration.x.ccms_user_api.url
    end

    def headers
      {
        "Content-Type" => "application/json",
        "Accept" => "application/json",
        "X-Authorization" => Rails.configuration.x.ccms_user_api.auth_key,
        "User-Agent" => "CivilApply/#{HostEnv.environment || 'host-env-missing'} Faraday/#{Faraday::VERSION}",
      }
    end
  end
end
