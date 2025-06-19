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

    # OPTIMIZE
    def collection
      @collection ||= sections.map.with_index(1) { |(name, tasks), index|
        if contains_subsections?(tasks)
          tasks[:subsections].map.with_index(1) do |(subname, subtasks), subindex|
            Subsection.new(
              application,
              name: name.to_s,
              sub_name: subname.to_s,
              tasks: subtasks,
              index: show_index ? index : nil,
              display_section_header: subindex.eql?(1),
            )
          end
        else
          Section.new(
            application,
            name: name.to_s,
            tasks: tasks,
            index: show_index ? index : nil,
            body_override: tasks[:body_override]&.call(application),
          )
        end
      }.flatten
    end

    def sections
      raise "implement SECTIONS, in subclasses" unless self.class.const_defined?(:SECTIONS)

      self.class::SECTIONS
    end

    def contains_subsections?(tasks)
      tasks.include?(:subsections) && !tasks[:body_override]&.call(application)
    end
  end
end
