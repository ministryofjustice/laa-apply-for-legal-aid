class ResendLinkRequestMailer < GovukNotifyRails::Mailer
  include NotifyTemplateMethods

  def notify(legal_aid_application)
    template_name :new_link_request
    set_personalisation(
      applicant_name: legal_aid_application.applicant_full_name,
      provider: legal_aid_application.provider_id,
      application_ref: legal_aid_application.application_ref,
      requested_at: Time.current.to_s(:datetime)
    )
    mail to: support_email_address
  end
end
