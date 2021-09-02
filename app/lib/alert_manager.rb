class AlertManager
  class << self
    def capture_exception(exception)
      return unless sendable?(exception)

      alert_klass.capture_exception(exception)
    end

    def capture_message(message)
      return unless sendable?(message)

      alert_klass.capture_message(message)
    end

    def alert_klass
      Setting.setting.alert_via_sentry? ? Sentry : SlackAlerter
    end

    def sendable?(message_or_exception)
      return false unless HostEnv.environment.in?(%i[production uat])

      return false if geckoboard_too_many_messages_error?(message_or_exception)

      true
    end

    def geckoboard_too_many_messages_error?(exception)
      return true if exception.is_a?(Geckoboard::UnexpectedStatusError) && exception.message =~ /^You have exceeded the API rate limit/

      false
    end
  end

  private_class_method :alert_klass, :sendable?, :geckoboard_too_many_messages_error?
end
