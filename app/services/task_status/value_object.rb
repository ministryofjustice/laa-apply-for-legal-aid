module TaskStatus
  StatusData = Data.define(:value, :tag_classes)

  class ValueObject
    attr_accessor :value

    STATUSES = [
      COMPLETED = StatusData.new(:completed, nil),
      IN_PROGRESS = StatusData.new(:in_progress, "govuk-tag govuk-tag--light-blue"),
      NOT_STARTED =  StatusData.new(:not_started, "govuk-tag govuk-tag--blue"),
      CANNOT_START = StatusData.new(:cannot_start, "govuk-tag govuk-tag--grey"),
      UNREACHABLE = StatusData.new(:unreachable, nil),
      NOT_APPLICABLE = StatusData.new(:not_applicable, "govuk-tag govuk-tag--grey"),
      UNKNOWN = StatusData.new(:unknown, nil),
    ].freeze

    # add getter? and setter methods for each status value
    STATUSES.each do |status|
      define_method :"#{status.value}?" do
        value == status.value
      end

      define_method :"#{status.value}!" do
        self.value = status.value
        self
      end
    end

    def initialize
      @value = :unknown
    end

    # Should this be part of the value object as it represents presentation layer logic?!
    delegate :tag_classes, to: :current_status

    def valid?
      STATUSES.include?(current_status)
    end

    def enabled?
      [IN_PROGRESS, NOT_STARTED].include?(current_status)
    end

    def current_status
      STATUSES.find { |status| status.value == value }
    end
  end
end
