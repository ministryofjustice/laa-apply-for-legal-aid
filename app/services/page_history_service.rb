class PageHistoryService
  def initialize(page_history_id:)
    @page_history_id = page_history_id
  end

  def write(page_history)
    return if page_history == []

    redis.call("DEL", redis_key)
    redis.call("RPUSH", redis_key, page_history)
  end

  def read
    redis.call("LRANGE", redis_key, 0, -1)
  end

private

  def redis
    # TODO: do we need to consider thread safety/implement a connection pool here?
    @redis ||= redis_config.new_client
  end

  def redis_config
    @redis_config ||= RedisClient.config(url: redis_url)
  end

  def redis_url
    Rails.configuration.x.redis.page_history_url
  end

  def redis_key
    @redis_key ||= "page_history:#{@page_history_id}"
  end
end
