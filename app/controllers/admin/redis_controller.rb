# :nocov:
module Admin
  class RedisController < ApplicationController
    def index
      @values = values
    end

    def create
      create_record
      redirect_to admin_redis_path
    end

    private

    def redis
      @redis ||= Redis.new(url: redis_url)
    end

    def values
      return if redis_keys.empty?

      Raven.caputure_message "REDIS KEYS: #{redis_keys.inspect}"

      redis.keys.map { |key| [key, redis.get(key)] }
    end

    def redis_keys
      @redis_keys ||= redis.keys
    end

    def create_record
      key = session[:session_id]
      serialised_values = redis.get(key)
      values = serialised_values.nil? ? [] : JSON.parse(serialised_values)
      values << Time.now.strftime('%H:%M:%S')
      redis.set(key, values.to_json)
    end

    def redis_url
      url = "rediss://:#{ENV['REDIS_PASSWORD']}@#{ENV['REDIS_HOST']}:6379/2" if ENV['REDIS_HOST'].present? && ENV['REDIS_PASSWORD'].present?
      url || 'redis://localhost/2'
    end
  end
end
# :nocov:
