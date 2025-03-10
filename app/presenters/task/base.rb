# A Task::List is a hash

module Task
  class Base
    include ActionView::Helpers::TagHelper
    include ActionView::Context
    include Rails.application.routes.url_helpers

    DEFAULT_STATUS_TAG_CLASSES = %w[app-task-list__tag].freeze

    def self.build(application, name)
      class_name = "Task::#{name.camelize}"

      if const_defined?(class_name)
        class_name.constantize.new(application, name:)
      else
        new(application, name:)
      end
    end

    attr_accessor :application, :name

    delegate :t!, to: I18n
    delegate :completed?, to: :status

    def initialize(application, name:)
      @application = application
      @name = name
    end

    def render
      tag.li class: "govuk-task-list__item govuk-task-list__item--with-link" do
        safe_join(
          [task_name, status_tag],
        )
      end
    end

    def path
      raise "Implement in subclass"
    end

    # Default for subclasses is to use a "task status" object of the same name.
    # You may prefer to override in subclasses, particularly if additional arguments
    # need passing.
    def status
      return @status if @status

      task_status_klass = "TaskStatus::#{name.camelize}"

      if self.class.const_defined?(task_status_klass)
        @status = task_status_klass.constantize.new(application).call
      else
        raise "#{task_status_klass} not implemented! Follow task list pattern or overide in subclass."
      end
    end

  private

    def task_name
      tag.div class: "app-task-list__task-name govuk-task-list__name-and-hint" do
        task_name_or_link
      end
    end

    def task_name_or_link
      if status.enabled?
        tag.a t!("task_list.task.#{name}"),
              class: "govuk-link govuk-task-list__link",
              href: path,
              aria: { describedby: tag_id }
      else
        t!("task_list.task.#{name}")
      end
    end

    def status_tag
      tag.div id: tag_id, class: status_tag_classes do
        t!("task_list.status.#{status.value}")
      end
    end

    def status_tag_classes
      DEFAULT_STATUS_TAG_CLASSES | Array(status.tag_classes)
    end

    def tag_id
      [name, "status"].join("-")
    end
  end
end
