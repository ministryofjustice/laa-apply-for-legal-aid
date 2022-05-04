class Rack::Attack
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  Rack::Attack.blocklist("block all crawlergo feedback") do |request|
    request.body.string.match?(/[C|c]rawlergo/) && request.path.include?("feedback") && request.post?
  end

  Rack::Attack.throttle("prevent feedback spamming", limit: 2, period: 10) do |request|
    block = request.path.include?("feedback") && request.post?
    request.ip if block
  end
end
