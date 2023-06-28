module CFECivil
  class BaseService
    HEADER_VERSION = 1.0

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
        "Accept" => "application/json;version=#{cfe_version}",
        "User-Agent" => "CivilApply/#{HEADER_VERSION} #{HostEnv.environment.to_s || 'missing'}",
      }
    end

    def cfe_version
      "6"
    end
  end
end
