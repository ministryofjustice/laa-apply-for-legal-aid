class CitizenEmailService
  attr_reader :application

  include Rails.application.routes.url_helpers

  def initialize(application)
    @application = application
  end

  def send_email
    ScheduledMailing.send_now!(mailer_klass: NotifyMailer,
                               mailer_method: :citizen_start_email,
                               legal_aid_application_id: application.id,
                               addressee: applicant.email_address,
                               arguments: mailer_args)
    notify_dashboard
  end

  private

  def notify_dashboard
    ActiveSupport::Notifications.instrument 'dashboard.applicant_emailed', legal_aid_application_id: @application.id
  end

  def mailer_args
    [
      application.application_ref,
      applicant.email_address,
      application_url,
      applicant.full_name,
      provider.firm.name
    ]
  end

  def provider
    application&.provider
  end

  def application_url
    @application_url ||= citizens_legal_aid_application_url(secure_id)
  end

  def applicant
    @applicant ||= application&.applicant
  end

  def secure_id
    application.generate_secure_id
  end
end
