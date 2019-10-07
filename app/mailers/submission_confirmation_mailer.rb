class SubmissionConfirmationMailer < GovukNotifyRails::Mailer
  require_relative 'concerns/notify_template_methods'
  include NotifyTemplateMethods

  def notify(legal_aid_application, provider, applicant)
    template_name :submission_confirmation
    set_personalisation(
      provider_name: provider['name'],
      client_name: "#{applicant['first_name']} #{applicant['last_name']}".strip,
      ref_number: legal_aid_application['application_ref']
    )
    mail to: provider['email']
  end
end
