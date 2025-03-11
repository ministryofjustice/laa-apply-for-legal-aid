module TaskList
  class ItemStatus
    def status(task_class:, application:)
      statuses[task_class] ||=
        task_class.new(application: application, item_statuses: self).current_status
    end

    def self_status(task:)
      statuses[task.class] ||= task.current_status
    end

  private

    def statuses
      @statuses ||= {}
    end
  end
end
