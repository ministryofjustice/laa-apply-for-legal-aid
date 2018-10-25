class NotifyMailer < GovukNotifyRails::Mailer
  def citizen_start_email(app_ref, email, application_url, client_name)
    set_template_conf
    set_personalisation(application_url: application_url, client_name: client_name, ref_number: app_ref)
    mail(to: email)
  end

  protected

  def set_template_conf
    template_id = template_ids.fetch(:citizen_start_application)
    set_template(template_id)
  end

  def template_ids
    @template_ids ||= Rails.configuration.govuk_notify_templates
  end
end
