module TaskStatus
  module Validators
    class ProceedingsTypes < Base
      def valid?
        return false if proceedings.empty?

        proceedings.all? do |proceeding|
          TaskList::ProceedingType.new(used_delegated_functions: proceeding.used_delegated_functions,
                                       used_delegated_functions_on: proceeding.used_delegated_functions_on,
                                       client_involvement_type_ccms_code: proceeding.client_involvement_type_ccms_code,
                                       substantive_level_of_service: proceeding.substantive_level_of_service,
                                       emergency_level_of_service: proceeding.emergency_level_of_service,
                                       accepted_emergency_defaults: proceeding.accepted_emergency_defaults,
                                       accepted_substantive_defaults: proceeding.accepted_substantive_defaults,
                                       ccms_matter_code: proceeding.ccms_matter_code).valid?
        end && emergency_cost_override_form.valid?
      end

    private

      delegate :proceedings, to: :application

      def emergency_cost_override_form
        LegalAidApplications::EmergencyCostOverrideForm.new(model: application)
      end
    end
  end
end
