class SubmitCitizenFinancialReminderMailer < BaseApplyMailer
  require_relative 'concerns/notify_template_methods'
  include NotifyTemplateMethods

  def self.eligible_for_delivery?(scheduled_mailing)
    scheduled_mailing.legal_aid_application.provider_step == 'check_provider_answers'
  end

  def notify_citizen(application_id, email, application_url, client_name, url_expiry_date)
    application = LegalAidApplication.find(application_id)
    template_name :reminder_to_submit_financial_information_client
    set_personalisation(
      ref_number: application['application_ref'],
      client_name: client_name,
      application_url: application_url,
      expiry_date: url_expiry_date
    )
    mail(to: email)
  end
end
