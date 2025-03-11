module TaskList
  class Item < BaseRenderer
    delegate :status, to: :task
    delegate :completed?, to: :status
    attr_reader :item_statuses

    def initialize(application, name:, item_statuses:)
      super(application, name:)

      @item_statuses = item_statuses
    end

    def render
      tag.li class: "govuk-task-list__item govuk-task-list__item--with-link" do
        safe_join(
          [task_name, status_tag],
        )
      end
    end

  private

    def task_name
      tag.div class: "app-task-list__task-name govuk-task-list__name-and-hint" do
        task_link
      end
    end

    def task_link
      if status.enabled?
        tag.a t!("tasklist.task.#{name}"),
              class: "govuk-link govuk-task-list__link",
              href: task.path,
              aria: { describedby: tag_id }
      else
        t!("tasklist.task.#{name}")
      end
    end

    def status_tag
      StatusTag.new(application, name:, status:).render
    end

    def task
      @task ||= Task::Base.build(name, application:, item_statuses:)
    end
  end
end
