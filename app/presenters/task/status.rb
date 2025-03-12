module Task
  class Status
    VALUES = [
      COMPLETED = :completed,
      IN_PROGRESS = :in_progress,
      NOT_STARTED = :not_started,
      CANNOT_START = :cannot_start,
      UNREACHABLE = :unreachable,
      NOT_APPLICABLE = :not_applicable,
    ].freeze

    def self.enabled?(status)
      [COMPLETED, IN_PROGRESS, NOT_STARTED].include?(status)
    end
  end
end
