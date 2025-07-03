# A Task::List is a hash

module Task
  class Base
    include ActionView::Helpers::TagHelper
    include ActionView::Context
    include Rails.application.routes.url_helpers

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

    # :nocov:
    def path
      raise "Task::#{name.camelize}.path not implemented. Implement in subclass."
    end
    # :nocov:

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
      # TODO: Disable all tasks until we are ready to unlock the sections
      # t!("task_list.task.#{name}")
      #
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
      tag.div id: tag_id, class: "govuk-task-list__status" do
        tag_component.colour.nil? ? tag_component.text : tag_component.call
      end
    end

    def tag_component
      @tag_component ||= GovukComponent::TagComponent.new(text: t!("task_list.status.#{status.value}"), colour: status.colour)
    end

    def tag_id
      [name, "status"].join("-")
    end
  end
end
