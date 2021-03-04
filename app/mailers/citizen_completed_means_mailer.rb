class CitizenCompletedMeansMailer < BaseApplyMailer
  require_relative 'concerns/notify_template_methods'
  include NotifyTemplateMethods

  def notify_provider(application_id, provider_name, applicant_name, application_url, to = support_email_address)
    application = LegalAidApplication.find(application_id)
    template_name :client_completed_means
    set_personalisation(
      email: to,
      provider_name: provider_name,
      applicant_name: applicant_name,
      ref_number: application.application_ref,
      application_url: application_url
    )
    mail to: to
  end
end
