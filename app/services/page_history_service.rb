class PageHistoryService
  def initialize(session_id:)
    @session_id = session_id
  end

  def write(page_history)
    redis.set(redis_key, page_history)
  end

  def read
    redis.get(redis_key)
  end

  private

  def redis
    @redis ||= Redis.new(url: redis_url)
  end

  def redis_url
    Rails.configuration.x.redis.page_history_url
  end

  def redis_key
    @redis_key ||= "page_history:#{@session_id}"
  end
end
