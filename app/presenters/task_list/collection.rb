module TaskList
  class Collection < SimpleDelegator
    attr_reader :view, :application, :show_index

    delegate :size, :count, to: :all_tasks
    delegate :tag, :safe_join, to: :view

    def initialize(view, application:, show_index: true)
      @view = view
      @application = application
      @show_index = show_index

      super(collection)
    end

    def render
      tag.ol class: "govuk-task-list" do
        safe_join(map(&:render))
      end
    end

    def completed
      @completed ||= all_tasks.select(&:completed?)
    end

  private

    def all_tasks
      @all_tasks ||= map(&:items).flatten
    end

    def collection
      @collection ||= sections.map.with_index(1) do |(name, tasks), index|
        Section.new(
          application,
          name: name.to_s,
          tasks: displayable_tasks(tasks, application),
          index: show_index ? index : nil,
          body_override: tasks[:body_override]&.call(application),
        )
      end
    end

    def sections
      raise "implement SECTIONS, in subclasses" unless self.class.const_defined?(:SECTIONS)

      self.class::SECTIONS
    end

    def displayable_tasks(tasks, application)
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
