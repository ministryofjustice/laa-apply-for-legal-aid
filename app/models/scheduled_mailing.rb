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
    Raven.capture_exception(e)
  end

  def cancel!
    update!(cancelled_at: Time.now)
  end
end
