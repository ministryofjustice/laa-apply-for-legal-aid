module TaskList
  class SectionRenderer
    include ActionView::Helpers::TagHelper
    include ActionView::Context

    attr_reader :application, :name, :tasks, :index, :body_override, :display_section_header
    alias_method :display_section_header?, :display_section_header

    delegate :t!, to: I18n

    def initialize(application, name:, tasks:, index:, body_override: nil, display_section_header: true)
      @application = application
      @name = name
      @tasks = tasks
      @index = index
      @body_override = body_override
      @display_section_header = display_section_header
    end

    # :nocov:
    def render
      raise "implement in subclasses"
    end
    # :nocov:

  private

    def header
      return unless display_section_header?

      tag.h2 class: "govuk-task-list__section" do
        if index
          tag.span class: "govuk-task-list__section-number" do
            "#{index}. ".concat(t!("task_list.heading.#{name}"))
          end
        else
          t!("task_list.heading.#{name}")
        end
      end
    end

    def body
      return body_override if body_override

      section_tasks
    end

    def section_tasks
      tag.ul class: "govuk-task-list__items" do
        safe_join(
          items.map(&:render),
        )
      end
    end

    def items
      @items ||= displayable_items.map do |name|
        name = name.call(application) if name.respond_to?(:call)

        Task::Base.build(application, name)
      end
    end

    def displayable_items
      tasks.filter { |_task, displayable_method_or_value|
        if displayable_method_or_value.respond_to?(:call)
          displayable_method_or_value.call(application)
        else
          displayable_method_or_value
        end
      }.keys.map(&:to_s)
    end
  end
end
