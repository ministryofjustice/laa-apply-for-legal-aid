class SubmitApplicationReminderService
  def initialize(application)
    @application = application
  end

  def send_email
    return unless application.substantive_application_deadline_on

    scheduled_mail.map(&:cancel!) if scheduled_mail.present?

    [five_days_before_deadline, nine_am_deadline_day].each do |scheduled_time|
      application.scheduled_mailings.create!(
        mailer_klass: 'SubmitApplicationReminderMailer',
        mailer_method: 'notify_provider',
        arguments: mailer_args,
        scheduled_at: scheduled_time
      )
    end
  end

  private

  attr_reader :application

  def scheduled_mail
    application.scheduled_mailings.where(mailer_klass: 'SubmitApplicationReminderMailer')
  end

  def mailer_args
    [
      application.id,
      application.provider.name,
      application.provider.email
    ]
  end

  def five_days_before_deadline
    five_days_before = WorkingDayCalculator.call(working_days: -5, from: application.substantive_application_deadline_on)
    five_days_before + 9.hours
  end

  def nine_am_deadline_day
    application.substantive_application_deadline_on + 9.hours
  end
end
