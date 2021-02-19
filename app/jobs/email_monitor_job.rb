class EmailMonitorJob < ApplicationJob
  queue_as :default

  DEFAULT_DELAY = 2.minutes.freeze
  END_OF_TIME = Time.zone.local(9999, 12, 31, 23, 59, 59)

  def perform
    ScheduledMailing.monitored.each { |mail| GovukEmails::Monitor.call(mail.id) }
    reschedule unless JobQueue.enqueued?(self.class)
  end

  private

  def reschedule
    self.class.set(wait: DEFAULT_DELAY).perform_later
  end
end
