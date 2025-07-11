module TaskStatus
  StatusData = Data.define(:value, :colour)

  class ValueObject
    attr_accessor :value

    STATUSES = [
      CANNOT_START = StatusData.new(:cannot_start, nil),
      NOT_READY = StatusData.new(:not_ready, "grey"),
      NOT_STARTED = StatusData.new(:not_started, "blue"),
      IN_PROGRESS = StatusData.new(:in_progress, "light-blue"),
      REVIEW = StatusData.new(:review, "yellow"),
      COMPLETED = StatusData.new(:completed, nil),
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
    delegate :colour, to: :current_status

    def valid?
      STATUSES.include?(current_status)
    end

    # Eventually COMPLETED will be added to this to unlock
    def enabled?
      [REVIEW, IN_PROGRESS, NOT_STARTED].include?(current_status)
    end

    def current_status
      STATUSES.find { |status| status.value == value }
    end
  end
end
