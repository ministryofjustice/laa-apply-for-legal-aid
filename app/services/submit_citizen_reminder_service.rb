class SubmitCitizenReminderService
  include Rails.application.routes.url_helpers

  def initialize(application)
    @application = application
  end

  def send_email
    [one_day_after_initial, nine_am_deadline_day].each do |scheduled_time|
      application.scheduled_mailings.create!(
        mailer_klass: 'SubmitCitizenFinancialReminderMailer',
        mailer_method: 'notify_citizen',
        arguments: mailer_args,
        scheduled_at: scheduled_time
      )
    end
  end

  private

  attr_reader :application

  def mailer_args
    [
      application.application_ref,
      applicant.email,
      application_url,
      applicant.full_name
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
    tomorrow = Date.today + 1.days
    tomorrow.to_time + 9.hours
  end

  def nine_am_deadline_day
    deadline = Date.today + 7.days
    deadline.to_time + 9.hours
  end
end
