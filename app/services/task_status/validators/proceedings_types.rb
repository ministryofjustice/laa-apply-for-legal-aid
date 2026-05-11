module TaskStatus
  module Validators
    class ProceedingsTypes < Base
      def valid?
        return false if proceedings.empty?

        super
      end

    private

      delegate :proceedings, to: :application

      def forms
        proceedings.flat_map { |proceeding| TaskStatus::Validators::ProceedingForms.new(proceeding).forms } << emergency_cost_override_form
      end

      def emergency_cost_override_form
        LegalAidApplications::EmergencyCostOverrideForm.new(model: application)
      end
    end
  end
end
