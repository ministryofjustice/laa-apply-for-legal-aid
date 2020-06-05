class SubmitCitizenReminderService
  include Rails.application.routes.url_helpers

  def initialize(application)
    @application = application
  end

  def send_email
    # return unless application.state == 'provider_assessing_means'
    # this might be better to check if it has passed a state rather than looking at anyone state in case it has progressed beyond
    # this state to e.g. provider_checking_citizens_means_answers
    # this might be better as single if statemnt, if state is client_details_answers_checked then send the email

    [one_day_after_initial, nine_am_deadline_day].each do |scheduled_time|
      application.scheduled_mailings.create!(
        mailer_klass: 'SubmitApplicantFinancialReminderMailer',
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
      application.id,
      application.applicant.email,
      application_url
    ]
  end

  def application_url
    @application_url ||= citizens_legal_aid_application_url(secure_id)
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
