module TaskStatus
  module Validators
    class ProceedingsTypes < Base
      def valid?
        return false if proceedings.empty?

        return false if emergency_scope_limitations.any?(false)

        return false if substantive_scope_limitations.any?(false)

        super
      end

    private

      delegate :proceedings, to: :application

      def forms
        [
          client_involvement_type_forms,
          delegated_functions_forms,
          emergency_defaults_forms,
          emergency_level_of_service_forms,
          final_hearings_emergency_forms,
          # emergency_scope_limitation_forms - doesn't use validator in the same way,
          substantive_defaults_forms,
          substantive_level_of_service_forms,
          final_hearings_substantive_forms,
          # substantive_scope_limitation_forms - doesn't use validator in the same way,
        ].flatten.compact
      end

      def client_involvement_type_forms
        proceedings.filter_map do |proceeding|
          Proceedings::ClientInvolvementTypeForm.new(model: proceeding)
        end
      end

      def delegated_functions_forms
        proceedings.filter_map do |proceeding|
          Proceedings::DelegatedFunctionsForm.new(model: proceeding)
        end
      end

      def emergency_defaults_forms
        proceedings.filter_map do |proceeding|
          next unless proceeding.uses_emergency_certificate?

          Proceedings::EmergencyDefaultsForm.new(model: proceeding)
        end
      end

      def emergency_level_of_service_forms
        proceedings.filter_map do |proceeding|
          Proceedings::EmergencyLevelOfServiceForm.new(model: proceeding) unless proceeding.accepted_emergency_defaults?
        end
      end

      def final_hearings_emergency_forms
        proceedings.filter_map do |proceeding|
          next unless proceeding.emergency_full_representation?

          Proceedings::FinalHearingForm.new(model: proceeding.emergency_final_hearing,
                                            listed: proceeding.emergency_final_hearing&.listed,
                                            date: proceeding.emergency_final_hearing&.date)
        end
      end

      def emergency_scope_limitations
        proceedings.map do |proceeding|
          proceeding.scope_limitations.emergency.any? unless proceeding.accepted_emergency_defaults?
        end
      end

      def substantive_defaults_forms
        proceedings.filter_map do |proceeding|
          Proceedings::SubstantiveDefaultsForm.new(model: proceeding)
        end
      end

      def substantive_level_of_service_forms
        proceedings.filter_map do |proceeding|
          Proceedings::SubstantiveLevelOfServiceForm.new(model: proceeding) unless proceeding.accepted_substantive_defaults?
        end
      end

      def final_hearings_substantive_forms
        proceedings.filter_map do |proceeding|
          next unless proceeding.substantive_full_representation?

          Proceedings::FinalHearingForm.new(model: proceeding.substantive_final_hearing,
                                            listed: proceeding.substantive_final_hearing&.listed,
                                            date: proceeding.substantive_final_hearing&.date)
        end
      end

      def substantive_scope_limitations
        proceedings.map do |proceeding|
          proceeding.scope_limitations.substantive.any? unless proceeding.accepted_substantive_defaults?
        end
      end
    end
  end
end
