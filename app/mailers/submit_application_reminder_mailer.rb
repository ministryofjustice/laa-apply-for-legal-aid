class SubmitApplicationReminderMailer < GovukNotifyRails::Mailer
  self.delivery_job = GovukNotifyMailerJob
  require_relative 'concerns/notify_template_methods'
  include NotifyTemplateMethods

  def notify_provider(application_id, name, to = support_email_address)
    application = LegalAidApplication.find(application_id)
    template_name :reminder_to_submit_an_application
    set_personalisation(
      email: to,
      provider_name: name,
      ref_number: application['application_ref'],
      client_name: application.applicant.full_name,
      delegated_functions_date: application['used_delegated_functions_on'].strftime('%d %B %Y'),
      deadline_date: application['substantive_application_deadline_on'].strftime('%d %B %Y')
    )
    mail to: to
  end
end
