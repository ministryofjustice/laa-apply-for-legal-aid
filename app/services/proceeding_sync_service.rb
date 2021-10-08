class ProceedingSyncService
  def initialize(application_proceeding_type)
    @application_proceeding_type = application_proceeding_type
    @proceeding_type = @application_proceeding_type.proceeding_type
    @substantive_scope_limitation = @proceeding_type.proceeding_type_scope_limitations
                                                    .where(substantive_default: true).first.scope_limitation
    @df_scope_limitation = @proceeding_type.proceeding_type_scope_limitations
                                           .where(delegated_functions_default: true).first.scope_limitation
  end

  def create!
    Proceeding.create(payload.merge(scope_limitations))
  end

  def update!
    proceeding_to_update_or_delete.update!(payload.merge(scope_limitations))
  end

  def destroy!
    proceeding_to_update_or_delete.destroy
  end

  private

  def proceeding_to_update_or_delete
    @proceeding_to_update_or_delete ||= Proceeding.where(legal_aid_application_id: @application_proceeding_type.legal_aid_application.id,
                                                         proceeding_case_id: @application_proceeding_type.proceeding_case_id).first
  end

  def payload
    {
      legal_aid_application_id: @application_proceeding_type.legal_aid_application.id,
      proceeding_case_id: @application_proceeding_type.proceeding_case_id,
      lead_proceeding: @application_proceeding_type.lead_proceeding,
      ccms_code: @proceeding_type.ccms_code,
      meaning: @proceeding_type.meaning,
      description: @proceeding_type.description,
      substantive_cost_limitation: @proceeding_type.default_cost_limitation_substantive,
      delegated_functions_cost_limitation: @proceeding_type.default_cost_limitation_delegated_functions,
      used_delegated_functions_on: @application_proceeding_type.used_delegated_functions_on,
      used_delegated_functions_reported_on: @application_proceeding_type.used_delegated_functions_reported_on,
      name: @proceeding_type.name
    }
  end

  def scope_limitations
    {
      substantive_scope_limitation_code: @substantive_scope_limitation.code,
      substantive_scope_limitation_meaning: @substantive_scope_limitation.meaning,
      substantive_scope_limitation_description: @substantive_scope_limitation.description,
      delegated_functions_scope_limitation_code: @df_scope_limitation.code,
      delegated_functions_scope_limitation_meaning: @df_scope_limitation.meaning,
      delegated_functions_scope_limitation_description: @df_scope_limitation.description
    }
  end
end
