module TaskStatus
  # This is relates to the capital CYA page but only for passported journeys :(
  # TODO: Rename all controllers, view namespaces and tasks to be called CheckPassportedCapitalAnswers
  #
  class CheckPassportedAnswers < Base
    def call
      status = ValueObject.new

      if not_applicable?
        status.not_applicable!
      else
        status.cannot_start!
        status.not_started! if not_started?
        status.in_progress! && in_progress?
        status.completed! if completed?
      end

      status
    end

  private

    def not_applicable?
      non_means_tested? || non_passported?
    end

    def not_started?
      false
    end

    def in_progress?
      false
    end

    def completed?
      false
    end
  end
end
