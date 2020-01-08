class SubmitApplicationReminderMailer < GovukNotifyRails::Mailer
  require_relative 'concerns/notify_template_methods'
  include NotifyTemplateMethods

  def notify_provider(application_or_id, name, to = support_email_address)
    # in order to still work for scheduled sidekiq jobs, allow application rather than application_id to be passed in
    # This can be changed to use just application id once all the scheduled mailer jobs in sidekiq have been delivered.

    application = application_or_id.is_a?(LegalAidApplication) ? application_or_id : LegalAidApplication.find(application_or_id)
    template_name :reminder_to_submit_an_application
    set_personalisation(
      email: to,
      provider_name: name,
      ref_number: application['application_ref'],
      delegated_functions_date: application['used_delegated_functions_on'],
      deadline_date: application['substantive_application_deadline_on']
    )
    mail to: to
  end
end
