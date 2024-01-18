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
    Slack::SendMessage.call(message)
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
  else
    message = { text: "RackAttack event #{match_type} '#{event_type}' was triggered from: #{ip_address}" }
  end
  Slack::SendMessage.call(message)
  Rails.logger.info message
end
