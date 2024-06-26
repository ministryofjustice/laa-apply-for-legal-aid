module LegalFramework
  class BaseApiCall
    def self.call(params = nil)
      params.nil? ? new.call : new(params).call
    end

  private

    def request
      conn.get url
    end

    def conn
      @conn ||= Faraday.new(url:, headers:)
    end

    def url
      "#{Rails.configuration.x.legal_framework_api_host}#{path}"
    end

    def headers
      { "Content-Type" => "application/json" }
    end
  end
end
