class UndeliverableEmailAlertMailer < BaseApplyMailer
  self.delivery_job = GovukNotifyMailerJob
  require_relative 'concerns/notify_template_methods'
  include NotifyTemplateMethods

  def notify_apply_team(email_address, failure_reason, mailer, mail_method, email_args)
    template_name :undeliverable_alert
    set_personalisation(
      email_address: email_address,
      failure_reason: failure_reason,
      mailer_and_method: "#{mailer}##{mail_method}",
      mail_params: email_args.to_json
    )

    mail to: Rails.configuration.x.support_email_address
  end
end
