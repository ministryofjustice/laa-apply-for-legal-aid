ActiveSupport::Notifications.subscribe(/dashboard/) do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  DashboardEventHandler.call(event)
end

ActiveSupport::Notifications.subscribe(/rack_attack/) do |_name, _start, _finish, _request_id, payload|
  request = payload[:request]
  event_type = request.env["rack.attack.matched"]
  match_type = request.env["rack.attack.match_type"]
  ip_address = match_type == :blocklist ? request.env["REMOTE_ADDR"] : request.env["rack.attack.match_discriminator"]

  case event_type
  when "block all crawlergo feedback"
    message = {
      text: {
        blocks: [
          {
            type: "section",
            text: {
              type: "mrkdwn",
              text: ":alert: *Rack::Attack - blocked crawlergo attack*\n\n We detected and blocked an attack from #{ip_address}",
            },
          },
        ],
      },
    }
  when "prevent feedback spamming"
    message = {
      text: {
        blocks: [
          {
            type: "section",
            text: {
              type: "mrkdwn",
              text: "*Rack::Attack - feedback spamming detected*\n\n We detected and blocked an feedback spamming attack from #{ip_address}",
            },
          },
        ],
      },
    }
  when "fail2ban/scripted-pen-testers"
    message = nil
    counting = Rack::Attack.cache.store.keys.find_all{ |k| k.include?(':count:') }.find_all { |ip| ip.include?(ip_address) }
    ban_key = Rack::Attack.cache.store.keys.find_all{ |k| k.include?(':ban:') }.find_all { |ip| ip.include?(ip_address) }
    infractions = counting.present? ? Rack::Attack.cache.store.read(counting) : 0
    banned = ban_key.present? ? Rack::Attack.cache.store.read(ban_key).eql?("1") : false
    time_left = ban_key.present? ? Rack::Attack.cache.store.ttl(ban_key) : 0
    ban_ends = time_left.positive? ? (Time.now() + time_left).strftime("%H:%M") : 0
    show_ban = banned && time_left.to_i > 3590 && infractions.eql?("3")
    Rails.logger.info "counting: #{counting}"
    Rails.logger.info "ban_key: #{ban_key}"
    Rails.logger.info "banned: #{banned}"
    Rails.logger.info "infractions: #{infractions}"
    Rails.logger.info "time_left: #{time_left}"
    Rails.logger.info "ban_ends: #{ban_ends}"
    Rails.logger.info "show_ban: #{show_ban}"
    message = { text: "Suspicious behaviour seen from #{ip_address}... monitoring in progress" } if infractions.eql?("1")
    message = { text: "Banned #{ip_address} until #{ban_ends} " } if show_ban
    Rails.logger.info "message.present?: #{message.present?}"
    Rails.logger.info "message: #{message}"
  else
    message = { text: "RackAttack event #{match_type} '#{event_type}' was triggered from: #{ip_address}" }
  end
  Rails.logger.info message
  Slack::SendMessage.call(message) if message.present?
end
