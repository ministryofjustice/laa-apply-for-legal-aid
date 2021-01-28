class ScheduledMailingsDeliveryJob < ApplicationJob
  queue_as :default

  def perform
    ScheduledMailing.due_now.map(&:deliver!)
  end
end
