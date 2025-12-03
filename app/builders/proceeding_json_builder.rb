class ProceedingJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      legal_aid_application_id:,
      proceeding_case_id:,
      lead_proceeding:,
      ccms_code:,
      meaning:,
      description:,
      substantive_cost_limitation:,
      delegated_functions_cost_limitation:,
      used_delegated_functions_on:,
      used_delegated_functions_reported_on:,
      created_at:,
      updated_at:,
      name:,
      matter_type:,
      category_of_law:,
      category_law_code:,
      ccms_matter_code:,
      client_involvement_type_ccms_code:,
      client_involvement_type_description:,
      used_delegated_functions:,
      emergency_level_of_service:,
      emergency_level_of_service_name:,
      emergency_level_of_service_stage:,
      substantive_level_of_service:,
      substantive_level_of_service_name:,
      substantive_level_of_service_stage:,
      accepted_emergency_defaults:,
      accepted_substantive_defaults:,
      sca_type:,
      related_orders:,

      # nested relations below this line
      scope_limitations: scope_limitations.map { |sl| ScopeLimitationJsonBuilder.build(sl).as_json },
      final_hearings: final_hearings.map { |fh| FinalHearingJsonBuilder.build(fh).as_json },
    }
  end
end
