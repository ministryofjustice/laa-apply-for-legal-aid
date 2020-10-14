class PageHistoryService
  def initialize(page_history_id:)
    @page_history_id = page_history_id
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
    @redis_key ||= "page_history:#{@page_history_id}"
  end
end
