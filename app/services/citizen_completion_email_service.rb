class CitizenCompletionEmailService
  include Rails.application.routes.url_helpers

  def initialize(application)
    @application = application
  end

  def send_email
    ScheduledMailing.send_now!(mailer_klass: CitizenConfirmationMailer,
                               mailer_method: :citizen_complete_email,
                               legal_aid_application_id: application.id,
                               addressee: applicant.email_address,
                               arguments: mailer_args)
  end

  private

  attr_reader :application

  def mailer_args
    [
      application.application_ref,
      applicant.email_address,
      applicant.full_name
    ]
  end

  def applicant
    @applicant ||= application&.applicant
  end
end
