module LegalFramework
  class BaseApiCall
    attr_reader :redis

    def initialize
      @redis = Redis.new(url: Rails.configuration.x.redis.lfa_url)
    end

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

    def read_or_store_values
      json = redis.get(redis_key)
      return json unless json.nil?

      write_to_cache(redis_key, yield)
      redis.get(redis_key)
    end

    def write_to_cache(key, data)
      redis.set(key, data, ex: Rails.configuration.x.legal_framework.cache_duration)
    end
  end
end
