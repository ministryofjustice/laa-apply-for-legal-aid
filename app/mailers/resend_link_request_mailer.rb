class ResendLinkRequestMailer < BaseApplyMailer
  require_relative 'concerns/notify_template_methods'
  include NotifyTemplateMethods

  def notify(app_id, email, application_url, client_name)
    template_name :new_link_to_client
    set_personalisation(
      application_url: application_url,
      client_name: client_name,
      ref_number: app_id,
      expiry_date: url_expiry_date
    )
    mail(to: email)
  end
end
