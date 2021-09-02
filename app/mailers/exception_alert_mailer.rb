class ExceptionAlertMailer < BaseApplyMailer
  require_relative 'concerns/notify_template_methods'
  include NotifyTemplateMethods

  def notify(environment:, details:, to:)
    template_name :exception_alert
    set_personalisation(environment: environment, details: details)
    mail to: to
  end
end
