module TaskList
  class Section < BaseRenderer
    # attr_reader :tasks, :index, :item_statuses
    attr_reader :tasks, :index

    def initialize(application, name:, tasks:, index:)
      super(application, name:)

      @tasks = tasks
      @index = index
    end

    # def initialize(application, name:, tasks:, index:, item_statuses:)
    #   super(application, name:)

    #   @item_statuses = item_statuses
    #   @tasks = tasks
    #   @index = index
    # end

    def render
      tag.li do
        safe_join(
          [section_header, section_tasks],
        )
      end
    end

    def items
      @items ||= tasks.map do |name|
        name = name.call(application) if name.respond_to?(:call)

        # Item.new(application, name:, item_statuses:)
        Item.new(application, name:)
      end
    end

  private

    def section_header
      tag.h2 class: "govuk-task-list__section" do
        if index
          tag.span class: "govuk-task-list__section-number" do
            "#{index}. ".concat(t!("tasklist.heading.#{name}"))
          end
        else
          t!("tasklist.heading.#{name}")
        end
      end
    end

    def section_tasks
      tag.ul class: "govuk-task-list__items" do
        safe_join(
          items.map(&:render),
        )
      end
    end
  end
end
