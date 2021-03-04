class EmailMonitorJob < ApplicationJob
  queue_as :default

  DEFAULT_DELAY = 2.minutes.freeze

  def perform
    ScheduledMailing.monitored.each { |mail| GovukEmails::Monitor.call(mail.id) }
    reschedule unless JobQueue.enqueued?(self.class)
  end

  private

  def reschedule
    self.class.set(wait: DEFAULT_DELAY).perform_later
  end
end
