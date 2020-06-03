class SubmitApplicationReminderService
  def initialize(application)
    @application = application
  end

  def send_provider_email
    return unless application.substantive_application_deadline_on

    [five_days_before_deadline, nine_am_deadline_day].each do |scheduled_time|
      application.scheduled_mailings.create!(
        mailer_klass: 'SubmitApplicationReminderMailer',
        mailer_method: 'notify_provider',
        arguments: provider_mailer_args,
        scheduled_at: scheduled_time
      )
    end
  end

  def send_citizen_email
    # return unless application.state

    [one_day_after_initial, right_the_fuck_now].each do |scheduled_time|
      application.scheduled_mailings.create!(
          mailer_klass: 'SubmitApplicantFinancialReminderMailer',
          mailer_method: 'notify_citizen',
          arguments: citizen_mailer_args,
          scheduled_at: scheduled_time
      )
    end
  end

  private

  attr_reader :application

  def provider_mailer_args
    [
      application.id,
      application.provider.name,
      application.provider.email
    ]
  end

  def citizen_mailer_args
    [
        application.id,
        application.applicant.email
    ]
  end

  def five_days_before_deadline
    five_days_before = WorkingDayCalculator.call(working_days: -5, from: application.substantive_application_deadline_on)
    five_days_before.to_time + 9.hours
  end

  def nine_am_deadline_day
    application.substantive_application_deadline_on.to_time + 9.hours
  end

  def one_day_after_initial
    # one_day_after = WorkingDayCalculator.call(working_days: +1, from: Date.today)
    # one_day_after.to_time + 9.hours
    tomorrow = (Date.today +1).to_time + 9.hours
    # tomorrow.to_time + 9.hours
  end

  def right_the_fuck_now
    in_15_mins = Time.current
    in_15_mins.to_time + 10.minutes
  end

  # def citizen_nine_am_deadline_day
  #   # application.substantive_application_deadline_on.to_time + 9.hours
  #   application 'date url will expire, 7 days from date created + 9 hours (so it is sent at 9am)'
  # end
end
