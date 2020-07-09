class SubmitProviderReminderService
  include Rails.application.routes.url_helpers

  def initialize(application)
    @application = application
  end

  def send_email
    application.scheduled_mailings.create!(
      mailer_klass: 'SubmitProviderFinancialReminderMailer',
      mailer_method: 'notify_provider',
      arguments: mailer_args,
      scheduled_at: two_days_after_initial
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
    two_days_after = WorkingDayCalculator.call(working_days: +2, from: Date.today)
    two_days_after.to_time + 9.hours
  end
end
