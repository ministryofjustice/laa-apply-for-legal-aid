class UndeliverableEmailAlertMailer < BaseApplyMailer
  require_relative "concerns/notify_template_methods"
  include NotifyTemplateMethods

  def notify_apply_team(scheduled_mail_id)
    scheduled_mail = ScheduledMailing.find(scheduled_mail_id)
    template_name :undeliverable_alert
    set_personalisation(
      email_address: scheduled_mail.addressee,
      failure_reason: scheduled_mail.status,
      mailer_and_method: "#{scheduled_mail.mailer_klass}##{scheduled_mail.mailer_method}",
      mail_params: scheduled_mail.arguments,
    )

    mail to: Rails.configuration.x.support_email_address
  end

  def notify_provider(provider_email, application_ref, applicant_name, applicant_email)
    template_name :client_email_failed_provider_alert
    set_personalisation(
      ref_number: application_ref,
      applicant_name:,
      applicant_email:,
    )

    mail to: provider_email
  end
end
