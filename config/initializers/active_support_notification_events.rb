ActiveSupport::Notifications.subscribe(/dashboard/) do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  DashboardEventHandler.call(event)
end
