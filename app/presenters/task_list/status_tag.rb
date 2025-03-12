module TaskList
  class StatusTag < BaseRenderer
    attr_reader :status

    DEFAULT_CLASSES = %w[app-task-list__tag].freeze

    STATUS_TAG_CLASSES = {
      ::Task::Status::COMPLETED => nil,
      ::Task::Status::IN_PROGRESS => "govuk-tag govuk-tag--light-blue",
      ::Task::Status::NOT_STARTED => "govuk-tag govuk-tag--blue",
      ::Task::Status::UNREACHABLE => nil,
      ::Task::Status::CANNOT_START => "govuk-tag govuk-tag--grey",
      ::Task::Status::NOT_APPLICABLE => "govuk-tag govuk-tag--grey",
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
      DEFAULT_CLASSES | Array(STATUS_TAG_CLASSES.fetch(status))
    end
  end
end
