module TaskList
  class StatusTag < BaseRenderer
    attr_reader :status

    DEFAULT_CLASSES = %w[app-task-list__tag].freeze

    STATUS_CLASSES = {
      ::TaskStatus::COMPLETED => nil,
      ::TaskStatus::IN_PROGRESS => "govuk-tag govuk-tag--light-blue",
      ::TaskStatus::NOT_STARTED => "govuk-tag govuk-tag--blue",
      ::TaskStatus::UNREACHABLE => nil,
      ::TaskStatus::NOT_APPLICABLE => "govuk-tag govuk-tag--grey",
    }.freeze

    def initialize(application, name:, status:)
      super(application, name:)
      @status = status
    end

    def render
      tag.div id: tag_id, class: tag_classes do
        t!("tasklist.status.#{status}")
      end
    end

  private

    def tag_classes
      DEFAULT_CLASSES | Array(STATUS_CLASSES.fetch(status))
    end
  end
end
