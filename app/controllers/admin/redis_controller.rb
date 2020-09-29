module Admin
  class RedisController < ApplicationController

    def index
      @values = values
    end

    def new

    end

    def create
      create_record
      redirect_to admin_redis_path
    end

    private

    def redis
      @redis ||= Redis.new(host: '0.0.0.0', db: 2)
    end

    def values
      redis.keys.map{ |key| [key, redis.get(key)] }
    end

    def create_record
      key = session[:session_id]
      serialised_values = redis.get(key)
      values = serialised_values.nil? ? [] : JSON.parse(serialised_values)
      values << Time.now.strftime('%H:%M:%S')
      redis.set(key, values.to_json)
    end
  end
end
