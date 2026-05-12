module TaskStatus
  module Validators
    class ProceedingsTypes < Base
      def valid?
        return false if proceedings.empty?

        proceedings.all? { |proceeding| ProceedingType.new(proceeding).valid? } && emergency_cost_override_form.valid?
      end

    private

      delegate :proceedings, to: :application

      def emergency_cost_override_form
        LegalAidApplications::EmergencyCostOverrideForm.new(model: application)
      end
    end
  end
end
