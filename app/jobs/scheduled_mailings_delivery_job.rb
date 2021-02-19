class ScheduledMailingsDeliveryJob < ApplicationJob
  queue_as :default

  DEFAULT_DELAY = 2.minutes.freeze

  def perform
    ScheduledMailing.waiting.past_due.each do |scheduled_mail|
      GovukEmails::DeliveryMan.call(scheduled_mail.id)
    end
    reschedule unless JobQueue.enqueued?(ScheduledMailingsDeliveryJob)
    EmailMonitorJob.perform_later unless JobQueue.enqueued?(EmailMonitorJob)
  end

  def reschedule
    self.class.set(wait: DEFAULT_DELAY).perform_later
  end
end
