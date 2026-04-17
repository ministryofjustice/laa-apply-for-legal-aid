module TaskStatus
  class Partner < Base
  private

    def perform(status)
      status.cannot_start! unless previous_tasks_completed?
      status.not_started! if not_started?
      status.in_progress! if in_progress?
      status.completed! if completed?
      status.not_needed! if not_needed?
    end

    def not_needed?
      application.overriding_dwp_result? || application.non_means_tested?
    end

    def not_started?
      return @not_started if defined?(@not_started)

      @not_started = previous_tasks_completed? && application.applicant&.has_partner.nil?
    end

    def in_progress?
      return @in_progress if defined?(@in_progress)

      @in_progress = previous_tasks_completed? && application.applicant&.has_partner.present? && !partner_valid?
    end

    def completed?
      return @completed if defined?(@completed)

      @completed = partner_valid?
    end

    def partner_valid?
      @partner_valid ||= Validators::Partner.new(application).valid?
    end

    def previous_task_status_items
      @previous_task_status_items ||= [
        Applicants,
        MakeLink,
        ProceedingsTypes,
      ]
    end
  end
end
