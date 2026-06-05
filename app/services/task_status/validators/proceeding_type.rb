module TaskStatus
  module Validators
    class ProceedingType
      include ::DurationLogger

      attr_reader :proceeding

      delegate :client_involvement_type_ccms_code,
               :client_involvement_type_description,
               :accepted_emergency_defaults,
               :accepted_emergency_defaults?,
               :emergency_level_of_service,
               :emergency_level_of_service_name,
               :emergency_level_of_service_stage,
               :final_hearings,
               :emergency_final_hearing,
               :accepted_substantive_defaults,
               :accepted_substantive_defaults?,
               :substantive_level_of_service,
               :substantive_level_of_service_name,
               :substantive_level_of_service_stage,
               :used_delegated_functions?,
               :special_children_act?,
               :emergency_full_representation?,
               :substantive_full_representation?,
               :scope_limitations,
               to: :proceeding

      def initialize(proceeding)
        @proceeding = proceeding
      end

      def valid?
        forms.all?(&:valid?)
          && client_involvement_type_valid?
          # && emergency_defaults_valid?
          && emergency_level_of_service_valid?
          # && emergency_scope_limitations_valid?
          # && substantive_defaults_valid?
          && substantive_level_of_service_valid?
        # && substantive_scope_limitations_valid?
      end

    private

      def forms
        [
          # client_involvement_type_form, # calls LegalFramework::ClientInvolvementTypes::Proceeding
          delegated_functions_form,
          emergency_defaults_form, # calls LegalFramework::ProceedingTypes::Defaults.call
          # emergency_level_of_service_form, # calls LegalFramework::ProceedingTypes::Proceeding.call
          emergency_final_hearings_form,
          emergency_scope_limitations_form, # calls LegalFramework::ProceedingTypes::Scopes.call
          substantive_defaults_form, # calls LegalFramework::ProceedingTypes::Defaults.call
          # substantive_level_of_service_form, # calls LegalFramework::ProceedingTypes::Proceeding.call
          substantive_final_hearings_form,
          substantive_scope_limitations_form, # calls LegalFramework::ProceedingTypes::Scopes.call
        ].flatten.compact
      end

      # DOABLE: It is not the job of the task list to verify the actual code and description are valid values
      # But can save and come back later leave form valid from this perspective but invalid on the form
      def client_involvement_type_valid?
        client_involvement_type_ccms_code.present?
        && client_involvement_type_description.present?
      end

      # def client_involvement_type_form
      #   Proceedings::ClientInvolvementTypeForm.new(model: proceeding) # calls LFA
      # end

      def delegated_functions_form
        Proceedings::DelegatedFunctionsForm.new(model: proceeding)
      end

      # BLOCKER: Cannot check the validity of existing defaults without using CIT in LFA query
      # def emergency_defaults_valid?
      #   true if !used_delegated_functions? || special_children_act?

      #   [true, false].include?(accepted_emergency_defaults)
      # end

      def emergency_defaults_form
        return if !used_delegated_functions? || special_children_act?

        Proceedings::EmergencyDefaultsForm.new(model: proceeding)
      end

      # The form only validates default levels of service chosen and populates it name
      # The LFA lookup checks the LoS per proceeding so we do not need to validate these
      # values again.
      def emergency_level_of_service_valid?
        return true if used_delegated_functions? && !accepted_emergency_defaults?

        emergency_level_of_service.present?
          && emergency_level_of_service_name.present?
          && emergency_level_of_service_stage.present?
      end

      # def emergency_level_of_service_form
      #   return @emergency_level_of_service_form if defined?(@emergency_level_of_service_form)

      #   @emergency_level_of_service_form =
      #     if used_delegated_functions? && !accepted_emergency_defaults?
      #       Proceedings::EmergencyLevelOfServiceForm.new(model: proceeding)
      #     end
      # end

      def emergency_final_hearings_form
        return unless used_delegated_functions?
        return unless emergency_changed_to_full_rep?

        # TODO: We need to verify that the proceeding requires a final hearing or not based on whether the
        # proceedings has more than one applicable service levels. if more than one and they changed to
        # full rep/3 then they have to answer the final hearing question. However, this basic check for
        # existence may suffice!!
        return unless final_hearings.emergency.exists?

        # REMOVED: How can we check this form just using database fields, currently it requires an LFA call.
        # return unless emergency_level_of_service_form&.levels_of_service.to_a.length > 1

        Proceedings::FinalHearingForm.new(model: emergency_final_hearing)
      end

      def emergency_changed_to_full_rep?
        emergency_full_representation? && !accepted_emergency_defaults?
      end

      def emergency_scopes
        JSON.parse(LegalFramework::ProceedingTypes::Scopes.call(proceeding, true))["level_of_service"]["scope_limitations"]
      end

      def emergency_scope_limitations_form
        return unless used_delegated_functions?
        return if accepted_emergency_defaults?
        return if emergency_level_of_service.blank?

        Proceedings::ScopeLimitationsForm.call(emergency_scopes, model: proceeding, scope_type: :emergency)
      end

      # BLOCKER: Cannot check the validity of existing scopes without using CIT in LFA query
      #
      # def emergency_scope_limitations_valid?
      #   return true unless used_delegated_functions?
      #   return true if accepted_emergency_defaults?
      #   return true if emergency_level_of_service.blank?
      #
      #   Proceedings::ScopeLimitationsForm.call(emergency_scopes_from_db, model: proceeding, scope_type: :emergency).valid?
      # end

      # def emergency_scopes_from_db
      #   scope_limitations.where(scope_type: :emergency).map do |db_scope|
      #     {
      #       "code" => db_scope.code,
      #       "meaning" => db_scope.meaning,
      #       "description" => db_scope.description,
      #       "additional_params" => [],
      #       # "additional_params" => db_scope.additional_params,
      #       # e.g.
      #       #  "additional_params" => [{"name" => "hearing_date", "type" => "date", "mandatory" => true}]},
      #     }
      #   end
      # end

      # BLOCKER: Cannot check the validity of default  scopes without using CIT in LFA query
      # def substantive_defaults_valid?
      #   [true, false].include?(accepted_substantive_defaults)
      # end

      def substantive_defaults_form
        Proceedings::SubstantiveDefaultsForm.new(model: proceeding)
      end

      # def substantive_level_of_service_form
      #   return @substantive_level_of_service_form if defined?(@substantive_level_of_service_form)

      #   @substantive_level_of_service_form =
      #     unless accepted_substantive_defaults?
      #       Proceedings::SubstantiveLevelOfServiceForm.new(model: proceeding)
      #     end
      # end

      # It is not the job of the task list to verify the actual levels of service are valid
      # only that the data the form will populate is present
      def substantive_level_of_service_valid?
        return true if accepted_substantive_defaults?

        substantive_level_of_service.present?
          && substantive_level_of_service_name.present?
          && substantive_level_of_service_stage.present?
      end

      def substantive_changed_to_full_rep?
        substantive_full_representation? && !accepted_substantive_defaults?
      end

      def substantive_final_hearings_form
        return unless substantive_changed_to_full_rep?

        # TODO: We need to verify that the proceeding requires a final hearing or not based on whether the
        # proceedings service levels are more than one. if more than one and they changed to full rep/3 then
        # they have to answer the final hearing question. However, this basic check for existence may suffice!!
        return unless final_hearings.substantive.exists?

        # REMOVED: How can we check this form just using database fields, currently it requires an LFA call.
        # return unless substantive_level_of_service_form&.levels_of_service.to_a.length > 1

        Proceedings::FinalHearingForm.new(model: substantive_final_hearing)
      end

      def substantive_scopes
        JSON.parse(LegalFramework::ProceedingTypes::Scopes.call(proceeding, false))["level_of_service"]["scope_limitations"]
      end

      def substantive_scope_limitations_form
        return if accepted_substantive_defaults?
        return if substantive_level_of_service.blank?

        Proceedings::ScopeLimitationsForm.call(substantive_scopes, model: proceeding, scope_type: :substantive)
      end

      # BLOCKER: Cannot check the validity of existing scopes without using CIT in LFA query
      #
      # def substantive_scope_limitations_valid?
      #   return true if accepted_substantive_defaults?
      #   return true if substantive_level_of_service.blank?

      #   Proceedings::ScopeLimitationsForm.call(substantive_scopes_from_db, model: proceeding, scope_type: :substantive).valid?
      # end

      # def substantive_scopes_from_db
      #   scope_limitations.where(scope_type: :substantive).map do |sl|
      #     {
      #       "code" => sl.code,
      #       "meaning" => sl.meaning,
      #       "description" => sl.description,
      #       "additional_params" => [],
      #       # TODO: as below
      #       # "additional_params" => sl.additional_params,
      #       # e.g.
      #       #  "additional_params" => [{"name" => "hearing_date", "type" => "date", "mandatory" => true}]},
      #     }
      #   end
      # end
    end
  end
end
