class ScheduledMailing < ApplicationRecord
  serialize :arguments, Array

  belongs_to :legal_aid_application

  scope :not_sent, -> { where(sent_at: nil) }
  scope :not_cancelled, -> { where(cancelled_at: nil) }
  scope :past_due, -> { where('scheduled_at < ?', Time.current) }

  def self.due_now
    not_sent.not_cancelled.past_due
  end

  def deliver!
    eligible_for_delivery? ? deliver_now : cancel!
  rescue StandardError => e
    Raven.capture_exception(e)
  end

  def cancel!
    update!(cancelled_at: Time.current)
  end

  private

  def deliver_now
    mailer_klass.constantize.__send__(mailer_method, *arguments).deliver_now
    update!(sent_at: Time.current)
  end

  def eligible_for_delivery?
    mailer_klass.constantize.__send__(:eligible_for_delivery?, self)
  end
end
