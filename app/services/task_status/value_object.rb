module TaskStatus
  class ValueObject
    attr_accessor :value

    VALUES = [
      COMPLETED = :completed,
      IN_PROGRESS = :in_progress,
      NOT_STARTED = :not_started,
      CANNOT_START = :cannot_start,
      UNREACHABLE = :unreachable,
      NOT_APPLICABLE = :not_applicable,
      UNKNOWN = :unknown,
    ].freeze

    TAG_CLASSES = {
      COMPLETED => nil,
      IN_PROGRESS => "govuk-tag govuk-tag--light-blue",
      NOT_STARTED => "govuk-tag govuk-tag--blue",
      UNREACHABLE => nil,
      CANNOT_START => "govuk-tag govuk-tag--grey",
      NOT_APPLICABLE => "govuk-tag govuk-tag--grey",
    }.freeze

    # add getter? and setter methods for each status value
    VALUES.each do |status|
      define_method :"#{status}?" do
        value == status
      end

      define_method :"#{status}!" do
        self.value = status
        self
      end
    end

    def initialize
      @value = :unknown
    end

    def valid?
      VALUES.include?(value)
    end

    def enabled?
      [COMPLETED, IN_PROGRESS, NOT_STARTED].include?(value)
    end

    # Should this be part of the value object as it represents presentation layer logic?!
    # See StatusTag class
    def tag_classes
      TAG_CLASSES[value]
    end
  end
end
