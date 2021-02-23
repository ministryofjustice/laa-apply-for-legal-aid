class AddAssignedScopeLimitationService
  def initialize(legal_aid_application, scope_type)
    @legal_aid_application = legal_aid_application
    @scope_type = scope_type
  end

  def self.call(legal_aid_application, scope_type)
    new(legal_aid_application, scope_type).call
  end

  def call
    case @scope_type
    when :substantive
      add_default_substantive_scope_limitation!
    when :delegated
      add_default_delegated_functions_scope_limitation!
    end
  end

  def add_default_substantive_scope_limitation!
    AssignedScopeLimitation.create!(
      application_proceeding_type_id: @legal_aid_application.application_proceeding_types.first.id,
      scope_limitation_id: @legal_aid_application.lead_proceeding_type.default_substantive_scope_limitation.id
    )
  end

  def add_default_delegated_functions_scope_limitation!
    AssignedScopeLimitation.create!(
      application_proceeding_type_id: @legal_aid_application.application_proceeding_type.id,
      scope_limitation_id: @legal_aid_application.lead_proceeding_type.default_delegated_functions_scope_limitation.id
    )
  end
end
