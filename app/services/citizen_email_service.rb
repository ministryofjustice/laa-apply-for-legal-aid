class CitizenEmailService
  include Rails.application.routes.url_helpers

  def initialize(legal_aid_application)
    @legal_aid_application = legal_aid_application
  end

  def send_email
    ScheduledMailing.send_now!(
      mailer_klass: NotifyMailer,
      mailer_method: :citizen_start_email,
      legal_aid_application_id: legal_aid_application.id,
      addressee: applicant.email_address,
      arguments: mailer_args,
    )
  end

private

  attr_reader :legal_aid_application

  delegate :applicant, :provider, to: :legal_aid_application, allow_nil: true

  def mailer_args
    [
      legal_aid_application.application_ref,
      applicant.email_address,
      citizens_legal_aid_application_url(access_token.token),
      applicant.full_name,
      provider.firm.name,
    ]
  end

  def access_token
    @access_token ||= legal_aid_application.generate_citizen_access_token!
  end
end
