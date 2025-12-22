class BankHolidayStore
  attr_reader :redis

  def initialize
    @redis = Redis.new(url: Rails.configuration.x.redis.bank_holidays_url)
  end

  def self.write(date_values)
    new.write(date_values)
  end

  def self.read
    new.read
  end

  def write(date_values)
    redis.set(redis_key, date_values.to_json)
  end

  def read
    json = redis.get(redis_key)

    JSON.parse(json)
  end

private

  def redis_key
    @redis_key ||= "bank_holiday_dates"
  end
end
