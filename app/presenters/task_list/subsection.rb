module TaskList
  class Subsection < BaseRenderer
    attr_reader :tasks, :index, :body_override, :sub_name, :display_section_header
    alias_method :display_section_header?, :display_section_header

    def initialize(application, name:, sub_name:, tasks:, index:, body_override: nil, display_section_header: true)
      super(application, name:)

      @sub_name = sub_name
      @tasks = tasks
      @index = index
      @body_override = body_override
      @display_section_header = display_section_header
    end

    def render
      tag.li do
        safe_join(
          [header, sub_header, body],
        )
      end
    end

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

    def sub_header
      tag.h3 class: "govuk-task-list__section" do
        t!("task_list.heading.#{sub_name}")
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
      @items ||= tasks.map do |name|
        name = name.call(application) if name.respond_to?(:call)

        Task::Base.build(application, name)
      end
    end
  end
end
