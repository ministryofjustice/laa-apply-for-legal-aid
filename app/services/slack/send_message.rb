module Slack
  class SendMessage
    def self.call(message)
      new(message).call
    end

    def initialize(message)
      raise "No slack webhook found" if webhook.nil?

      @message = message
    end

    def call
      request.body
    end

  private

    def webhook
      @webhook ||= ENV.fetch("SLACK_ALERT_WEBHOOK", nil)
    end

    def request
      conn.post do |request|
        request.body = @message.to_json
      end
    end

    def conn
      @conn ||= Faraday.new(url: webhook, headers:)
    end

    def headers
      { "Content-Type" => "application/json" }
    end
  end
end
