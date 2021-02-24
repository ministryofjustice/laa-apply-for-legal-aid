class RemoveScopeLimitationService
  def initialize(legal_aid_application)
    @legal_aid_application = legal_aid_application
  end

  def self.call(legal_aid_application)
    new(legal_aid_application).call
  end

  def call
    @legal_aid_application.application_proceeding_types.each do |application_proceeding_type|
      remove_df_scope(application_proceeding_type)
    end
  end

  private

  def remove_df_scope(application_proceeding_type)
    scope = default_df_scope(application_proceeding_type)

    remove_assigned_scope(application_proceeding_type, scope) if assigned_scope_limitations(application_proceeding_type, scope).first.scope_limitation_id.include?(scope.id)
  end

  def default_df_scope(application_proceeding_type)
    application_proceeding_type.proceeding_type.default_delegated_functions_scope_limitation
  end

  def assigned_scope_limitations(application_proceeding_type, scope)
    # application_proceeding_type.proceeding_type.assigned_scope_limitations
    AssignedScopeLimitation.where(application_proceeding_type_id: application_proceeding_type.id, scope_limitation_id: scope.id)
  end

  def remove_assigned_scope(application_proceeding_type, scope)
    # remove_me = application_proceeding_type.proceeding_type.assigned_scope_limitations.find_by(scope.id)
    remove_me = AssignedScopeLimitation.where(application_proceeding_type_id: application_proceeding_type.id, scope_limitation_id: scope.id).first
    # pp remove_me
    remove_me.destroy
  end
end
