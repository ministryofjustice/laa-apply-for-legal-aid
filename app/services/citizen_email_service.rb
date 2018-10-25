class CitizenEmailService
  include Rails.application.routes.url_helpers

  def initialize(application)
    @application = application
  end

  def send_email
    NotifyMailer.citizen_start_email(*mailer_args).deliver_later
  end

  private

  attr_reader :application

  def mailer_args
    [
      application.id,
      applicant.email_address,
      application_url,
      applicant.full_name
    ]
  end

  def application_url
    @application_url ||= citizens_legal_aid_application_url(application)
  end

  def applicant
    # TODO: This should probably raise an error if an applicant
    # does not exist as the citizen won't be able to start the
    # application.
    @applicant ||= application&.applicant
  end
end
