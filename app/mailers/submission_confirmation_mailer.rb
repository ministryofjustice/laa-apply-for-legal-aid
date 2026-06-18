class SubmissionConfirmationMailer < BaseApplyMailer
  require_relative "concerns/notify_template_methods"
  include NotifyTemplateMethods

  def notify(legal_aid_application_id, feedback_url)
    @legal_aid_application = LegalAidApplication.find(legal_aid_application_id)
    template_name :submission_confirmation
    set_personalisation(
      provider_name: provider.name,
      client_name: "#{first_name} #{last_name}",
      ref_number: @legal_aid_application.application_ref,
      feedback_url:,
    )
    mail to: provider.email
  end

private

  def first_name
    @legal_aid_application.applicant.first_name
  end

  def last_name
    @legal_aid_application.applicant.last_name
  end

  def provider
    @legal_aid_application.merits_submitted_by
  end
end
