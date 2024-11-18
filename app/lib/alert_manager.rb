class AlertManager
  class << self
    def capture_exception(exception)
      return unless sendable?

      alert_klass.capture_exception(exception)
    end

    def capture_message(message)
      return unless sendable?

      alert_klass.capture_message(message)
    end

    def alert_klass
      Setting.setting.alert_via_sentry? ? Sentry : SlackAlerter
    end

    def sendable?
      return false unless HostEnv.environment.in?(%i[production uat staging])

      true
    end
  end

  private_class_method :alert_klass, :sendable?
end
