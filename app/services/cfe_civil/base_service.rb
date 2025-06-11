module CFECivil
  class BaseService
    HEADER_VERSION = 1.0
    CFE_VERSION = "6".freeze

    def call
      @response = query_cfe_service
      process_response
    end

  private

    def conn
      @conn ||= Faraday.new(url: cfe_url_host, headers:)
    end

    def cfe_url_host
      Rails.configuration.x.cfe_civil_host
    end

    def headers
      {
        "Content-Type" => "application/json",
        "Accept" => "application/json;version=#{CFE_VERSION}",
        "User-Agent" => "CivilApply/#{HEADER_VERSION} #{HostEnv.environment || 'missing'}",
      }
    end
  end
end
