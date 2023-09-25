class OauthSessionSaver
  TIME_TO_LIVE_IN_SECONDS = 600

  def self.store(key, session)
    new.store(key, session)
  end

  def self.get(key)
    new.get(key)
  end

  def self.destroy!(key)
    new.destroy!(key)
  end

  def initialize
    redis_config ||= RedisClient.config(url: Rails.configuration.x.redis.oauth_session_url)
    @redis = redis_config.new_client
  end

  def store(key, session)
    return unless session.key?("omniauth.state")

    # session["ex"] = TIME_TO_LIVE_IN_SECONDS
    session.each do |hm_key, value|
      if value.is_a?(Array)
        @redis.call("HSET", key, hm_key, value.to_s)
      else
        @redis.call("HSET", key, hm_key, value)
      end
    end
    @redis.call("EXPIRE", key, TIME_TO_LIVE_IN_SECONDS)
  end

  def get(key)
    session_hash = @redis.call("HGETALL", key)
    return {} if session_hash.nil?

    session_hash
  end

  def destroy!(key)
    @redis.call("DEL", key)
  end
end
