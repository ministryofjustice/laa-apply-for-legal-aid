module TaskStatus
  module Validators
    class ProceedingsTypes < Base
      include ::DurationLogger

      def valid?
        return false if proceedings.empty?

        log_duration("TaskStatus::Validators::ProceedingsTypes#valid?") do
          proceedings.all? { |proceeding| ProceedingType.new(proceeding).valid? } && emergency_cost_override_form.valid?
        end
      end

    private

      delegate :proceedings, to: :application

      def emergency_cost_override_form
        LegalAidApplications::EmergencyCostOverrideForm.new(model: application)
      end
    end
  end
end
