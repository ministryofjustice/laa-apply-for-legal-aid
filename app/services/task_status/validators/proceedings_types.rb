module TaskStatus
  module Validators
    class ProceedingsTypes < Base
      include ::DurationLogger

      def valid?
        return false if proceedings.empty?

        results = nil

        log_duration("TaskStatus::Validators::ProceedingsTypes#valid?") do
          results = proceedings.all? { |proceeding| ProceedingType.new(proceeding).valid? } && emergency_cost_override_form.valid?
        end

        results
      end

    private

      delegate :proceedings, to: :application

      def emergency_cost_override_form
        LegalAidApplications::EmergencyCostOverrideForm.new(model: application)
      end
    end
  end
end
