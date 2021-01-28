module Dashboard
  class UpdaterJob < ApplicationJob
    include SuspendableJob
    queue_as :default

    def perform(widget_name)
      return if job_suspended?

      Dashboard::Widget.new(widget_name).run
    end
  end
end
