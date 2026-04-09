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
        proceedings.flat_map { |proceeding| forms_for(proceeding) } << emergency_cost_override_form
      end

      def forms_for(proceeding)
        emergency_level_form = emergency_level_of_service_form(proceeding)
        substantive_level_form = substantive_level_of_service_form(proceeding)
        [
          client_involvement_type_form(proceeding),
          delegated_functions_form(proceeding),
          emergency_defaults_form(proceeding),
          emergency_level_form,
          emergency_final_hearings_form(proceeding, emergency_level_form),
          emergency_scope_limitations_form(proceeding),
          substantive_defaults_form(proceeding),
          substantive_level_form,
          substantive_final_hearings_form(proceeding, substantive_level_form),
          substantive_scope_limitations_form(proceeding),
        ].flatten.compact
      end

      def client_involvement_type_form(proceeding)
        Proceedings::ClientInvolvementTypeForm.new(model: proceeding)
      end

      def delegated_functions_form(proceeding)
        Proceedings::DelegatedFunctionsForm.new(model: proceeding)
      end

      def emergency_defaults_form(proceeding)
        return if !proceeding.used_delegated_functions? || proceeding.special_children_act?

        Proceedings::EmergencyDefaultsForm.new(model: proceeding)
      end

      def emergency_level_of_service_form(proceeding)
        return unless proceeding.used_delegated_functions?
        return if proceeding.accepted_emergency_defaults?

        Proceedings::EmergencyLevelOfServiceForm.new(model: proceeding)
      end

      def emergency_final_hearings_form(proceeding, emergency_level_form)
        return unless proceeding.used_delegated_functions?
        return unless emergency_changed_to_full_rep?(proceeding)
        return unless emergency_level_form&.levels_of_service.to_a.length > 1

        Proceedings::FinalHearingForm.new(model: proceeding.emergency_final_hearing)
      end

      def emergency_changed_to_full_rep?(proceeding)
        proceeding.emergency_full_representation? && !proceeding.accepted_emergency_defaults?
      end

      def emergency_scopes(proceeding)
        JSON.parse(LegalFramework::ProceedingTypes::Scopes.call(proceeding, true))["level_of_service"]["scope_limitations"]
      end

      def emergency_scope_limitations_form(proceeding)
        return unless proceeding.used_delegated_functions?
        return if proceeding.accepted_emergency_defaults?
        return if proceeding.emergency_level_of_service.blank?

        Proceedings::ScopeLimitationsForm.call(emergency_scopes(proceeding), model: proceeding, scope_type: :emergency)
      end

      def substantive_defaults_form(proceeding)
        Proceedings::SubstantiveDefaultsForm.new(model: proceeding)
      end

      def substantive_level_of_service_form(proceeding)
        return if proceeding.accepted_substantive_defaults?

        Proceedings::SubstantiveLevelOfServiceForm.new(model: proceeding)
      end

      def substantive_changed_to_full_rep?(proceeding)
        proceeding.substantive_full_representation? && !proceeding.accepted_substantive_defaults?
      end

      def substantive_final_hearings_form(proceeding, substantive_level_form)
        return unless substantive_changed_to_full_rep?(proceeding)
        return unless substantive_level_form&.levels_of_service.to_a.length > 1

        Proceedings::FinalHearingForm.new(model: proceeding.substantive_final_hearing)
      end

      def substantive_scopes(proceeding)
        JSON.parse(LegalFramework::ProceedingTypes::Scopes.call(proceeding, false))["level_of_service"]["scope_limitations"]
      end

      def substantive_scope_limitations_form(proceeding)
        return if proceeding.accepted_substantive_defaults?
        return if proceeding.substantive_level_of_service.blank?

        Proceedings::ScopeLimitationsForm.call(substantive_scopes(proceeding), model: proceeding, scope_type: :substantive)
      end

      def emergency_cost_override_form
        LegalAidApplications::EmergencyCostOverrideForm.new(model: application)
      end
    end
  end
end
