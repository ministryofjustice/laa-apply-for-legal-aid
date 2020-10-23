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
    @redis = Redis.new(url: Rails.configuration.x.redis.oauth_session_url)
  end

  def store(key, session)
    return unless session.key?('omniauth.state')

    @redis.set(key, session.to_json, ex: TIME_TO_LIVE_IN_SECONDS)
  end

  def get(key)
    json = @redis.get(key)
    return {} if json.nil?

    JSON.parse(json)
  end

  def destroy!(key)
    @redis.del(key)
  end
end
