class SubmitCitizenFinancialReminderMailer < GovukNotifyRails::Mailer
  self.delivery_job = GovukNotifyMailerJob
  require_relative 'concerns/notify_template_methods'
  include NotifyTemplateMethods

  def self.eligible_for_delivery?(_scheduled_mailing)
    true
  end

  def notify_citizen(application_id, email, application_url, client_name)
    application = LegalAidApplication.find(application_id)
    template_name :reminder_to_submit_financial_information_client
    set_personalisation(
      ref_number: application['application_ref'],
      client_name: client_name,
      application_url: application_url
    )
    mail(to: email)
  end
end
