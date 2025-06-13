module TaskStatus
  class AboutFinancialMeans < Base
    def call
      status = ValueObject.new

      if passported?
        status.not_applicable!
      else
        status.cannot_start!
        status.not_started! if previous_sections.all?(&:completed?)
        status.in_progress! if in_progress?
        status.complete! if completed?
      end

      status
    end

  private

    def completed?
      # what is a completed means assessment?
      false
    end

    # TODO: this requires the instantiating and calling of all previous section's tasks and validators and is
    # therefore not effecient. We should be able to reuse the already collected results.
    def previous_sections
      [
        Applicants.new(application).call,
        ProceedingsTypes.new(application).call,
        # TODO: check DWP result
      ]
    end

    # TODO: check whether all sub forms for means are valid
    def in_progress?
      (applicant&.employed? || applicant&.armed_forces? || applicant&.self_employed?) && true
    end
  end
end
