class Rack::Attack
  Rack::Attack.cache.store = if Rails.configuration.x.redis.rack_attack_url
                               Redis.new(url: Rails.configuration.x.redis.rack_attack_url)
                             else
                               ActiveSupport::Cache::MemoryStore.new
                             end

  Rack::Attack.blocklist("block all crawlergo feedback") do |request|
    request.body.is_a?(StringIO) && request.body.string.match?(/[C|c]rawlergo/) && request.path.include?("feedback") && request.post?
  end

  Rack::Attack.throttle("prevent feedback spamming", limit: 2, period: 10) do |request|
    block = request.path.include?("feedback") && request.post?
    request.ip if block
  end
end
