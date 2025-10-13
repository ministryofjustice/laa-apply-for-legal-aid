module TaskStatus
  class DWPOutcome < Base
    def call
      status = ValueObject.new

      status.not_ready! if not_ready?
      status.not_started! if not_started?
      status.in_progress! if in_progress?
      status.completed! if completed?

      status
    end

  private

    def not_ready?
      !check_provider_answers_completed?
    end

    def not_started?
      check_provider_answers_completed? && application.dwp_result_confirmed.nil?
    end

    def in_progress?
      application.dwp_result_confirmed == false && !dwp_override_validator.valid?
    end

    def completed?
      provider_confirmed_dwp_result? || provider_overrode_dwp_result?
    end

    def provider_confirmed_dwp_result?
      application.dwp_result_confirmed == true && application.dwp_override.nil?
    end

    def provider_overrode_dwp_result?
      application.dwp_result_confirmed == false && dwp_override_validator.valid?
    end

    def check_provider_answers_completed?
      CheckProviderAnswers.new(application).call.completed?
    end

    def dwp_override_validator
      @dwp_override_validator ||= Validators::DWPOverride.new(application)
    end
  end
end
