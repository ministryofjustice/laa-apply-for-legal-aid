class ProceedingTypesService
  def initialize(legal_aid_application)
    @legal_aid_application = legal_aid_application
  end

  def add(proceeding_type_id: nil, scope_limitation: nil)
    return false unless proceeding_type_id && scope_limitation

    ActiveRecord::Base.transaction do
      @legal_aid_application.proceeding_types << proceeding_type(proceeding_type_id)
      AddScopeLimitationService.call(@legal_aid_application, scope_limitation)
    end
    true
  end

  private

  def proceeding_type(id)
    ProceedingType.find(id)
  end
end
