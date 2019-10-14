class SubmitApplicationReminderService
  def initialize(application)
    @application = application
  end

  def send_email
    return unless application.substantive_application_deadline_on

    # Must use bang version `deliver_later!` or failures won't be retried by sidekiq
    SubmitApplicationReminderMailer.notify_provider(*mailer_args).deliver_later!(wait_until: five_days_before_deadline)
    SubmitApplicationReminderMailer.notify_provider(*mailer_args).deliver_later!(wait_until: nine_am_deadline_day)
  end

  private

  attr_reader :application

  def mailer_args
    [
      application,
      application.provider.name,
      application.provider.email
    ]
  end

  def five_days_before_deadline
    five_days_before = WorkingDayCalculator.call(working_days: -5, from: application.substantive_application_deadline_on)
    five_days_before.to_time + 9.hours
  end

  def nine_am_deadline_day
    application.substantive_application_deadline_on.to_time + 9.hours
  end
end
