class CitizenCompletionEmailService
  include Rails.application.routes.url_helpers

  def initialize(application)
    @application = application
  end

  def send_email
    # Must use bang version `deliver_later!` or failures won't be retried by sidekiq
    CitizenConfirmationMailer.citizen_complete_email(*mailer_args).deliver_later!
  end

  private

  attr_reader :application

  def mailer_args
    [
        application.application_ref,
        applicant.email_address,
        applicant.full_name,
    ]
  end

  def applicant
    @applicant ||= application&.applicant
  end
end