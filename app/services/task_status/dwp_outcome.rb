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

    # OPTIMISE: causes call to CheckProviderAnswers.new(application).call which is expensive as it needs to check all prior tasks, but this is the only way to determine if the task can be started or not as the DWP outcome task is dependent on the Check your answers task being completed
    def not_ready?
      return @not_ready if defined?(@not_ready)

      @not_ready = !check_provider_answers_completed?
    end

    # OPTIMISE: causes call to CheckProviderAnswers.new(application).call which is expensive as it needs to check all prior tasks, but this is the only way to determine if the task can be started or not as the DWP outcome task is dependent on the Check your answers task being completed
    def not_started?
      return @not_started if defined?(@not_started)

      @not_started = check_provider_answers_completed? && application.dwp_result_confirmed.nil?
    end

    def in_progress?
      return @in_progress if defined?(@in_progress)

      @in_progress = application.dwp_result_confirmed == false && !dwp_override_validator_valid?
    end

    def completed?
      return @completed if defined?(@completed)

      @completed = provider_confirmed_dwp_result? || provider_overrode_dwp_result?
    end

    def provider_confirmed_dwp_result?
      return @provider_confirmed_dwp_result if defined?(@provider_confirmed_dwp_result)

      @provider_confirmed_dwp_result = application.dwp_result_confirmed == true && application.dwp_override.nil?
    end

    def provider_overrode_dwp_result?
      return @provider_overrode_dwp_result if defined?(@provider_overrode_dwp_result)

      @provider_overrode_dwp_result = application.dwp_result_confirmed == false && dwp_override_validator_valid?
    end

    def check_provider_answers_completed?
      return @check_provider_answers_completed if defined?(@check_provider_answers_completed)

      @check_provider_answers_completed =
        CheckProviderAnswers.new(application).call.completed?
    end

    def dwp_override_validator_valid?
      return @dwp_override_validator_valid if defined?(@dwp_override_validator_valid)

      @dwp_override_validator_valid =
        Validators::DWPOverride.new(application).valid?
    end
  end
end
