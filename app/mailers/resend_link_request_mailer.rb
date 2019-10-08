class ResendLinkRequestMailer < GovukNotifyRails::Mailer
  self.delivery_job = GovukNotifyMailerJob

  require_relative 'concerns/notify_template_methods'
  include NotifyTemplateMethods

  def notify(legal_aid_application, applicant, to = support_email_address)
    template_name :new_link_request
    set_personalisation(
      applicant_name: "#{applicant['first_name']} #{applicant['last_name']}".strip,
      provider: legal_aid_application['provider_id'],
      application_ref: legal_aid_application['application_ref'],
      requested_at: Time.current.to_s(:datetime)
    )
    mail to: to
  end
end
