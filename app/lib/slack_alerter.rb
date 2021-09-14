class SlackAlerter
  class << self
    def capture_message(message)
      send_alert(message)
    end

    def capture_exception(exception)
      send_alert(format_exception(exception))
    end

    def format_exception(exception)
      <<-END_OF_TEXT
      Exception raised: #{exception.class}
      Message: #{exception.message}

      Backtrace:
      #{exception.backtrace}
      END_OF_TEXT
    end

    def send_alert(message)
      raise 'Unable to send Slack Alert - SLACK_ALERT_EMAIL env var not configured' if slack_alert_email.nil?

      ExceptionAlertMailer.notify(
        environment: HostEnv.environment.to_s,
        details: message,
        to: slack_alert_email
      ).deliver_now!
    end

    def slack_alert_email
      ENV['SLACK_ALERT_EMAIL']
    end
  end

  private_class_method :format_exception, :send_alert, :slack_alert_email
end
