require "redis"

# Utility class to search for redis keys by name
# ,view their values and delete them
#
# Basic usage:
#
# scanner.call(/regex-for-keynames/)
# scanner.results
#
# Example usage:
#
# require_relative 'lib/utilities/redis_scanner'
#
# redis  = Redis.new(url: Rails.configuration.x.redis.base_url)
# scanner = Utilities::RedisScanner.new(redis)
#
# search for all keys that do not start with "stat"
# scanner.call(/^((?!stat:).)*$/)
#
# search for all keys that contain a namespace of an old non-existant host
# then delete them and check all deletions were successfull (1 indicates success)
# scanner.call(/live-0/)
# deleted_keys = scanner.delete_keys(dry_run: false)
# deleted_keys.values.tally
#
module Utilities
  class RedisScanner
    attr_reader :redis, :results

    REDIS_TYPE_METHOD_MAP = { string: :get, hash: :hgetall, list: :lrange, set: :smembers, zset: :zrangebyscore }.freeze

    def initialize(redis)
      @redis = redis
      @results = []
    end

    def call(search_term)
      @results = scan(search_term)
    end

    def values
      results.each_with_object({}) do |key, memo|
        memo[key] = redis.get(key)
      rescue Redis::CommandError
        redis_type = redis.type(key)
        redis_method = type_to_method(redis_type)

        # not all types and args catered for but does the job for typical sidekiq keys
        memo[key] = if redis_type == "zset"
                      redis.send(redis_method, key, 0, -1)
                    else
                      redis.send(redis_method, key)
                    end
      end
    end

    def delete_keys(dry_run: true)
      results.each_with_object({}) do |keyname, memo|
        if dry_run
          puts "[DRY-RUN] redis.del(#{keyname})"
        else
          memo[keyname] = redis.del(keyname)
        end
      end
    end

  private

    def scan(search_term)
      start = 0
      key_collection = []

      index, keys = redis.scan(start)
      while index != "0"
        start = index
        keys.each do |key|
          key_collection << key if key.match?(search_term)
        end
        index, keys = redis.scan(start)
      end

      key_collection
    end

    def type_to_method(redis_type)
      REDIS_TYPE_METHOD_MAP[redis_type.to_sym]
    end
  end
end
