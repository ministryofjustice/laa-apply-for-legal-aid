module TaskStatus
  class CapitalIntroductions < Base
    def call
      status = ValueObject.new

      if non_means_tested?
        status.not_applicable!
      else
        status.cannot_start!
        status.not_started! if not_started?
        status.in_progress! if in_progress?
        status.completed! if completed?
      end

      status
    end

  private

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
