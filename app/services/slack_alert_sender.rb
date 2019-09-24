class SlackAlertSender
  def self.call(message)
    new(message).call
  end

  attr_reader :message

  def initialize(message)
    @message = message
  end

  def call
    slack_client.ping(message) if webhook.present?
  end

  private

  def slack_client
    @slack_client ||= Slack::Notifier.new(webhook)
  end

  def webhook
    Rails.configuration.x.slack_alerts_webhook
  end
end
