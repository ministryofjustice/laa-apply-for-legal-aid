class SubmitCitizenReminderService
  include Rails.application.routes.url_helpers

  def initialize(legal_aid_application)
    @legal_aid_application = legal_aid_application
  end

  def send_email
    [day_after_initial_email, day_before_link_expires].each do |scheduled_time|
      ScheduledMailing.send_later!(
        mailer_klass: SubmitCitizenFinancialReminderMailer,
        mailer_method: :notify_citizen,
        legal_aid_application_id: legal_aid_application.id,
        addressee: applicant.email,
        scheduled_at: scheduled_time,
        arguments: mailer_args,
      )
    end
  end

private

  attr_reader :legal_aid_application

  delegate :applicant, to: :legal_aid_application, allow_nil: true

  def mailer_args
    [
      legal_aid_application.id,
      applicant.email,
      citizens_legal_aid_application_url(access_token.token),
      applicant.full_name,
      human_readable_expiry_date,
    ]
  end

  def access_token
    @access_token ||= legal_aid_application.generate_citizen_access_token!
  end

  def day_after_initial_email
    1.day.from_now.change(hour: 9)
  end

  def day_before_link_expires
    7.days.from_now.change(hour: 9)
  end

  def human_readable_expiry_date
    access_token.expires_on.advance(days: -1).strftime("%-d %B %Y")
  end
end
