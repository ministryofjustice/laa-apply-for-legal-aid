class SubmitApplicationReminderMailer < BaseApplyMailer
  require_relative 'concerns/notify_template_methods'
  include NotifyTemplateMethods

  INELIGIBLE_STATES = %w[use_ccms generating_reports submitting_assessment assessment_submitted].freeze

  def self.eligible_for_delivery?(scheduled_mailing)
    !scheduled_mailing.legal_aid_application.state.in?(INELIGIBLE_STATES)
  end

  def notify_provider(application_id, name, to = support_email_address)
    application = LegalAidApplication.find(application_id)
    template_name :reminder_to_submit_an_application
    set_personalisation(
      email: to,
      provider_name: name,
      ref_number: application['application_ref'],
      client_name: application.applicant.full_name,
      delegated_functions_date: application.earliest_delegated_functions_date&.strftime('%-d %B %Y'),
      deadline_date: application['substantive_application_deadline_on'].strftime('%-d %B %Y')
    )
    mail to: to
  end
end
