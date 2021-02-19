class ProviderEmailService
  include Rails.application.routes.url_helpers

  def initialize(application)
    @application = application
  end

  def send_email
    ScheduledMailing.send_now!(mailer_klass: CitizenCompletedMeansMailer,
                               mailer_method: :notify_provider,
                               legal_aid_application_id: @application.id,
                               addressee: provider_email_or_support,
                               arguments: mailer_args)
  end

  private

  attr_reader :application

  def mailer_args
    [
      application.id,
      provider.name,
      applicant.full_name,
      application_url,
      provider_email_or_support
    ]
  end

  def provider_email_or_support
    HostEnv.staging? ? Rails.configuration.x.support_email_address : provider.email
  end

  def application_url
    @application_url ||= providers_legal_aid_application_client_completed_means_url(application)
  end

  def applicant
    @applicant ||= application.applicant
  end

  def provider
    @provider ||= application.provider
  end
end
