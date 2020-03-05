class ScheduledMailing < ApplicationRecord
  serialize :arguments, Array

  belongs_to :legal_aid_application

  scope :not_sent, -> { where(sent_at: nil) }
  scope :not_cancelled, -> { where(cancelled_at: nil) }
  scope :past_due, -> { where('scheduled_at < ?', Time.now) }

  def self.due_now
    not_sent.not_cancelled.past_due
  end

  def deliver!
    mailer_klass.constantize.__send__(mailer_method, *arguments).deliver_now
    update!(sent_at: Time.now)
  rescue StandardError => e
    process_error(e)
  end

  def cancel!
    update!(cancelled_at: Time.now)
  end

  def process_error(error)
    Raven.capture_exception(error)
    SlackAlertSenderWorker.perform_async(format_error(error))
    false
  end

  def format_error(error)
    [
      '*Scheduled Mailing ERROR*',
      'An error has been raised by ScheduledMailing and logged to Sentry',
      "*Application* #{legal_aid_application_id}",
      "#{error.class}: #{error.message}"
    ].join("\n")
  end
end
