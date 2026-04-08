module TaskStatus
  class Partner < Base
    def call
      status = ValueObject.new

      return status.not_needed! if not_needed?
      return status.cannot_start! unless proceeding_types_validator
      return status.completed! if completed?
      return status.not_started! if not_started?

      status.in_progress!
    end

  private

    def not_needed?
      application.overriding_dwp_result? || application.non_means_tested?
    end

    def not_started?
      return @not_started if defined?(@not_started)

      @not_started = proceeding_types_validator && application.applicant&.has_partner.nil?
    end

    def completed?
      return @completed if defined?(@completed)

      @completed = partner_validator
    end

    def partner_validator
      @partner_validator ||= Validators::Partner.new(application).valid?
    end

    def proceeding_types_validator
      @proceeding_types_validator ||= Validators::ProceedingsTypes.new(application).valid?
    end
  end
end
