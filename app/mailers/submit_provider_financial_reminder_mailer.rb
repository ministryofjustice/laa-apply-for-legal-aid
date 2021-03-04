class SubmitProviderFinancialReminderMailer < BaseApplyMailer
  require_relative 'concerns/notify_template_methods'
  include NotifyTemplateMethods

  def self.eligible_for_delivery?(scheduled_mailing)
    scheduled_mailing.legal_aid_application.provider_step == 'client_completed_means'
  end

  def notify_provider(application_id, application_url)
    application = LegalAidApplication.find(application_id)
    template_name :reminder_to_submit_financial_information_provider
    set_personalisation(
      ref_number: application['application_ref'],
      client_name: application.applicant.full_name,
      application_url: application_url
    )
    mail to: application.provider.email
  end
end
