class ProceedingsConverter
  def call # rubocop:disable Metrics/MethodLength
    LegalAidApplication.all.each do |application|
      application.application_proceeding_types.each do |proceeding|
        next if application.proceedings.count == application.application_proceeding_types.count

        Proceeding.create(
          legal_aid_application_id: application.id,
          proceeding_case_id: proceeding.proceeding_case_id,
          lead_proceeding: proceeding.lead_proceeding,
          ccms_code: proceeding.proceeding_type.ccms_code,
          meaning: proceeding.proceeding_type.meaning,
          description: proceeding.proceeding_type.description,
          substantive_cost_limitation: proceeding.proceeding_type.default_cost_limitation_substantive,
          delegated_functions_cost_limitation: proceeding.proceeding_type.default_cost_limitation_delegated_functions,
          substantive_scope_limitation_code: proceeding.proceeding_type.proceeding_type_scope_limitations
                                                            .where(substantive_default: true).first.scope_limitation.code,
          substantive_scope_limitation_meaning: proceeding.proceeding_type.proceeding_type_scope_limitations
                                                            .where(substantive_default: true).first.scope_limitation.meaning,
          substantive_scope_limitation_description: proceeding.proceeding_type.proceeding_type_scope_limitations
                                                            .where(substantive_default: true).first.scope_limitation.description,
          delegated_functions_scope_limitation_code: proceeding.proceeding_type.proceeding_type_scope_limitations
                                                            .where(delegated_functions_default: true).first.scope_limitation.code,
          delegated_functions_scope_limitation_meaning: proceeding.proceeding_type.proceeding_type_scope_limitations
                                                            .where(delegated_functions_default: true).first.scope_limitation.meaning,
          delegated_functions_scope_limitation_description: proceeding.proceeding_type.proceeding_type_scope_limitations
                                                            .where(delegated_functions_default: true).first.scope_limitation.description,
          used_delegated_functions_on: proceeding.used_delegated_functions_on,
          used_delegated_functions_reported_on: proceeding.used_delegated_functions_reported_on
        )
      end
    end
  end
end
