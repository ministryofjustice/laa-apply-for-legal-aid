class UndeliverableEmailAlertMailer < BaseApplyMailer
  self.delivery_job = GovukNotifyMailerJob
  require_relative 'concerns/notify_template_methods'
  include NotifyTemplateMethods

  def notify_apply_team(addressee, failure_reason, mailer, mail_method)
    template_name :undeliverable_alert
    set_personalisation(
      environment: HostEnv.environment.upcase,
      addressee: addressee,
      failure_reason: failure_reason,
      mailer_and_method: "#{mailer}##{mail_method}"
    )

    mail to: Rails.configuration.x.support_email_address
  end
end
