class SubmitCitizenReminderService
  include Rails.application.routes.url_helpers

  def initialize(application)
    @application = application
  end

  def send_email
    [one_day_after_initial, nine_am_deadline_day].each do |scheduled_time|
      ScheduledMailing.send_later!(
        mailer_klass: SubmitCitizenFinancialReminderMailer,
        mailer_method: :notify_citizen,
        legal_aid_application_id: application.id,
        addressee: applicant.email,
        scheduled_at: scheduled_time,
        arguments: mailer_args
      )
    end
  end

  private

  attr_reader :application

  def mailer_args
    [
      application.id,
      applicant.email,
      application_url,
      applicant.full_name,
      url_expiry_date
    ]
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

  def one_day_after_initial
    tomorrow = Time.zone.today + 1.day
    tomorrow + 9.hours
  end

  def url_expiry_date
    (Time.zone.today + 7.days).strftime('%-d %B %Y')
  end

  def nine_am_deadline_day
    deadline = Time.zone.today + 7.days
    deadline + 9.hours
  end
end
