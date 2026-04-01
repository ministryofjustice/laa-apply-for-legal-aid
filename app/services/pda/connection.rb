module PDA
  class Connection
    extend Forwardable

    attr_reader :connection

    def_delegators :connection, :post, :get

    def initialize
      @connection = Faraday.new(url:, headers:)
    end

  private

    def url
      Rails.configuration.x.pda.url
    end

    def headers
      {
        "Content-Type" => "application/json",
        "Accept" => "application/json",
        "X-Authorization" => Rails.configuration.x.pda.auth_key,
        "User-Agent" => "CivilApply/#{HostEnv.environment || 'host-env-missing'} Faraday/#{Faraday::VERSION}",
      }
    end
  end
end
