class Rack::Attack
  Rack::Attack.cache.store = if Rails.configuration.x.redis.rack_attack_url
                               Redis.new(url: Rails.configuration.x.redis.rack_attack_url)
                             else
                               ActiveSupport::Cache::MemoryStore.new
                             end

  Rack::Attack.blocklist("block all crawlergo feedback") do |request|
    (request.body.is_a?(StringIO) && request.body.string.match?(/[C|c]rawlergo/)) && request.path.include?("feedback") && request.post?
  end

  Rack::Attack.throttle("prevent feedback spamming", limit: 2, period: 10) do |request|
    block = request.path.include?("feedback") && request.post?
    request.ip if block
  end

  Rack::Attack.blocklist('fail2ban/scripted-pen-testers') do |req|
    Rails.logger.info "inside fail2ban pen-testers"
    unless req.fullpath.match?("/assets/") || req.fullpath.eql?("/favicon.ico")
      Rails.logger.info "req: #{req.fullpath}"
      # `filter` returns truthy value if request fails, or if it's from a previously banned IP so the request is blocked
      Rack::Attack::Fail2Ban.filter("pen-tester-#{req.ip}", maxretry: 3, findtime: 10.minutes, bantime: 1.hour) do
        Rails.logger.info "inside pentesters-#{req.ip}"
        # The count for the IP is incremented if the return value is truthy
        match_found = CGI.unescape(req.query_string) =~ %r{/etc/passwd} ||
          req.path.include?('/etc/passwd') ||
          req.path.include?('wp-admin') ||
          req.path.include?('wp-login')||
          req.path.include?('.php')
        Rails.logger.info "blocking this? #{match_found}"
        match_found
      end
    end
  end
end
