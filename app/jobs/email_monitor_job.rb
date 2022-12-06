class EmailMonitorJob < ApplicationJob
  queue_as :default

  DEFAULT_DELAY = 2.minutes.freeze

  def perform
    ScheduledMailing.monitored.each do |mail|
      GovukEmails::Monitor.call(mail.id)
    end
  end
end
