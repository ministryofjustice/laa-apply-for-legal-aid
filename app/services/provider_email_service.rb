class ProviderEmailService
  include Rails.application.routes.url_helpers

  def initialize(application)
    @application = application
  end

  def send_email
    # Must use bang version `deliver_later!` or failures won't be retried by sidekiq
    CitizenCompletedMeansMailer.notify_provider(*mailer_args).deliver_later!
  end

  private

  attr_reader :application

  def mailer_args
    [
      application,
      provider.name,
      applicant.full_name,
      application_url,
      provider.email
    ]
  end

  def application_url
    @application_url ||= providers_legal_aid_applications_url
  end

  def applicant
    @applicant ||= application.applicant
  end

  def provider
    @provider ||= application.provider
  end
end
