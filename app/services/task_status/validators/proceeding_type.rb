module TaskStatus
  module Validators
    class ProceedingType
      attr_reader :proceeding

      def initialize(proceeding)
        @proceeding = proceeding
      end

      def valid?
        forms.all?(&:valid?)
      end

    private

      def forms
        [
          client_involvement_type_form,
          delegated_functions_form,
          emergency_defaults_form,
          emergency_level_of_service_form,
          emergency_final_hearings_form,
          emergency_scope_limitations_form,
          substantive_defaults_form,
          substantive_level_of_service_form,
          substantive_final_hearings_form,
          substantive_scope_limitations_form,
        ].flatten.compact
      end

      def client_involvement_type_form
        Proceedings::ClientInvolvementTypeForm.new(model: proceeding)
      end

      def delegated_functions_form
        Proceedings::DelegatedFunctionsForm.new(model: proceeding)
      end

      def emergency_defaults_form
        return if !proceeding.used_delegated_functions? || proceeding.special_children_act?

        Proceedings::EmergencyDefaultsForm.new(model: proceeding)
      end

      def emergency_level_of_service_form
        return @emergency_level_of_service_form if defined?(@emergency_level_of_service_form)

        @emergency_level_of_service_form =
          if proceeding.used_delegated_functions? && !proceeding.accepted_emergency_defaults?
            Proceedings::EmergencyLevelOfServiceForm.new(model: proceeding)
          end
      end

      def emergency_final_hearings_form
        return unless proceeding.used_delegated_functions?
        return unless emergency_changed_to_full_rep?
        return unless emergency_level_of_service_form&.levels_of_service.to_a.length > 1

        Proceedings::FinalHearingForm.new(model: proceeding.emergency_final_hearing)
      end

      def emergency_changed_to_full_rep?
        proceeding.emergency_full_representation? && !proceeding.accepted_emergency_defaults?
      end

      def emergency_scopes
        JSON.parse(LegalFramework::ProceedingTypes::Scopes.call(proceeding, true))["level_of_service"]["scope_limitations"]
      end

      def emergency_scope_limitations_form
        return unless proceeding.used_delegated_functions?
        return if proceeding.accepted_emergency_defaults?
        return if proceeding.emergency_level_of_service.blank?

        Proceedings::ScopeLimitationsForm.call(emergency_scopes, model: proceeding, scope_type: :emergency)
      end

      def substantive_defaults_form
        Proceedings::SubstantiveDefaultsForm.new(model: proceeding)
      end

      def substantive_level_of_service_form
        return @substantive_level_of_service_form if defined?(@substantive_level_of_service_form)

        @substantive_level_of_service_form =
          unless proceeding.accepted_substantive_defaults?
            Proceedings::SubstantiveLevelOfServiceForm.new(model: proceeding)
          end
      end

      def substantive_changed_to_full_rep?
        proceeding.substantive_full_representation? && !proceeding.accepted_substantive_defaults?
      end

      def substantive_final_hearings_form
        return unless substantive_changed_to_full_rep?
        return unless substantive_level_of_service_form&.levels_of_service.to_a.length > 1

        Proceedings::FinalHearingForm.new(model: proceeding.substantive_final_hearing)
      end

      def substantive_scopes
        JSON.parse(LegalFramework::ProceedingTypes::Scopes.call(proceeding, false))["level_of_service"]["scope_limitations"]
      end

      def substantive_scope_limitations_form
        return if proceeding.accepted_substantive_defaults?
        return if proceeding.substantive_level_of_service.blank?

        Proceedings::ScopeLimitationsForm.call(substantive_scopes, model: proceeding, scope_type: :substantive)
      end
    end
  end
end
