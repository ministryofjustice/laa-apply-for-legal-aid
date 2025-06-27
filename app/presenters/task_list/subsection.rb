module TaskList
  class Subsection < SectionRenderer
    attr_reader :sub_name

    def initialize(application, name:, sub_name:, tasks:, index:, body_override: nil, display_section_header: true)
      super(application, name:, tasks:, index:, body_override:, display_section_header:)

      @sub_name = sub_name
    end

    def render
      tag.li do
        safe_join(
          [header, sub_header, body],
        )
      end
    end

  private

    def sub_header
      tag.h3 class: "govuk-task-list__section" do
        t!("task_list.heading.#{sub_name}")
      end
    end
  end
end
