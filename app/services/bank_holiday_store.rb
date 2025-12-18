class BankHolidayStore
  attr_reader :redis

  def initialize
    @redis = Redis.new(url: Rails.configuration.x.redis.bank_holidays_url)
  end

  def self.write(date_values)
    new.write(date_values)
  end

  def self.read(fallback_to_api_for_cache_miss: true)
    new.read(fallback_to_api_for_cache_miss:)
  end

  def self.destroy!
    new.destroy!
  end

  def write(date_values)
    redis.set(redis_key, date_values.to_json)
  end

  # when key does not exist we query API, write response to cache for the next hit, and return the API response. If API query
  # is nil or any other error we log, alert on it and return an empty array. The empty array will allow out of hours access on bank holidays
  # but is better than denying access. The purpose of this is to enable resilience and fallbacks both for UAT branches - that may not have
  # a cached bank holiday store - and for potential cache misses on any environment due to unexpected cache key eviction or expiry.
  # In addition any JSON parse errors will be raised and fallback to empty array so as not to block access.
  def read(fallback_to_api_for_cache_miss: true)
    json = redis.get(redis_key)

    if json.nil? && fallback_to_api_for_cache_miss
      Rails.logger.info("#{self.class.name} cache miss, fetching latest data from API")
      raise StandardError, "#{self.class.name} cache miss, fetching latest data from API returned no dates" if latest_dates.blank?

      write(latest_dates)
      latest_dates
    else
      JSON.parse(json)
    end
  rescue StandardError => e
    Rails.logger.error("#{self.class.name} read error: #{e.message}")
    Sentry.capture_message("#{self.class.name} read error: #{e.message}")
    []
  end

  def destroy!
    redis.del(redis_key)
  end

private

  def redis_key
    @redis_key ||= "bank_holiday_dates"
  end

  def latest_dates
    @latest_dates ||= BankHolidayRetriever.dates
  end
end
