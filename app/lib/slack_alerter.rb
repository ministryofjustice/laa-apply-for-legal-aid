class SlackAlerter
  SLACK_CHANNEL_EMAIL = 'apply-alerts-prod-aaaabbocbcpykkqticw7skurte@mojdt.slack.com'.freeze

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
      ExceptionAlertMailer.notify(
        environment: HostEnv.environment.to_s,
        details: message,
        to: SLACK_CHANNEL_EMAIL
      ).deliver_now!
    end
  end

  private_class_method :format_exception, :send_alert
end
