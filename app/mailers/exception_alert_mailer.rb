class ExceptionAlertMailer < BaseApplyMailer
  require_relative "concerns/notify_template_methods"
  include NotifyTemplateMethods

  def notify(environment:, details:, to:)
    template_name :exception_alert
    set_personalisation(environment:, details:)
    mail to:
  end
end
