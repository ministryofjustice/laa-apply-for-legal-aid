class AlertManager
  def self.capture_exception(exception)
    alert_conduit.capture_exception(exception)
  end

  def self.capture_message(message)
    alert_conduit.capture_message(message)
  end

  def self.alert_conduit
    Setting.setting.alert_via_sentry? ? Sentry : SlackAlerter
  end
end
