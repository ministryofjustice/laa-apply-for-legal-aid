class SubmitProviderReminderService
  include Rails.application.routes.url_helpers

  def initialize(application)
    @application = application
  end

  def send_email
    ScheduledMailing.send_later!(
      mailer_klass: SubmitProviderFinancialReminderMailer,
      mailer_method: :notify_provider,
      legal_aid_application_id: @application.id,
      addressee: @application.provider.email,
      scheduled_at: two_days_after_initial,
      arguments: mailer_args
    )
  end

  private

  attr_reader :application

  def mailer_args
    [
      application.id,
      application_url
    ]
  end

  def application_url
    @application_url ||= providers_legal_aid_application_client_completed_means_url(application)
  end

  def two_days_after_initial
    two_days_after = WorkingDayCalculator.call(working_days: +2, from: Time.zone.today)
    two_days_after + 9.hours
  end
end
