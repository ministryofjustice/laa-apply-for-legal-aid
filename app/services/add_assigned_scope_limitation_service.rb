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
      add_default_delegated_functions_scope_limitations!
    end
  end

  def add_default_substantive_scope_limitation!
    AssignedScopeLimitation.create!(
      application_proceeding_type_id: application_proceeding_type_id,
      scope_limitation_id: @legal_aid_application.lead_proceeding_type.default_substantive_scope_limitation.id
    )
  end

  def add_default_delegated_functions_scope_limitations!
    current_scopes = ApplicationProceedingType.where(
      legal_aid_application_id: @legal_aid_application.id
    )

    current_scopes.each do |scope|
      AssignedScopeLimitation.create!(
        application_proceeding_type_id: scope.id,
        scope_limitation_id: @legal_aid_application.proceeding_types.find_by(id: scope.proceeding_type_id).default_delegated_functions_scope_limitation.id
      )
    end
  end

  def application_proceeding_type_id
    @legal_aid_application.application_proceeding_types.order(created_at: :desc).first.id
  end
end
