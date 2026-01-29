class SubmitApplicationReminderService
  attr_reader :application

  def initialize(application)
    @application = application
  end

  def send_email
    return unless application.substantive_application_deadline_on

    return if application.substantive_application_deadline_on < Date.current

    scheduled_mail.presence&.map(&:cancel!)

    schedule_new_mails
  end

  def schedule_new_mails
    [five_days_before_deadline, nine_am_deadline_day].each do |scheduled_time|
      ScheduledMailing.send_later!(
        mailer_klass: SubmitApplicationReminderMailer,
        mailer_method: :notify_provider,
        legal_aid_application_id: application.id,
        addressee:,
        scheduled_at: scheduled_time,
        arguments: mailer_args,
      )
    end
  end

private

  def addressee
    HostEnv.staging? ? Rails.configuration.x.support_email_address : application.provider.email
  end

  def scheduled_mail
    application.scheduled_mailings.where(mailer_klass: "SubmitApplicationReminderMailer")
  end

  def mailer_args
    [
      application.id,
      application.provider.name,
      addressee,
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
