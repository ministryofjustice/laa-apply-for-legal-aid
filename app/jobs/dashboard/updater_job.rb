module Dashboard
  class UpdaterJob < ActiveJob::Base
    queue_as :default

    def perform(widget_name)
      Dashboard::Widget.new(widget_name).run
    end
  end
end
