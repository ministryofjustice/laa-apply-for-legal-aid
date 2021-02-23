class ProceedingTypesService
  def initialize(legal_aid_application)
    @legal_aid_application = legal_aid_application
  end

  def add(proceeding_type_id: nil, scope_limitation: nil)
    return false unless proceeding_type_id && scope_limitation

    ActiveRecord::Base.transaction do
      @legal_aid_application.reset_proceeding_types! unless Setting.allow_multiple_proceedings? # This will probably change when multiple proceeding types implemented!
      @legal_aid_application.proceeding_types << proceeding_type(proceeding_type_id)
      AddScopeLimitationService.call(@legal_aid_application, scope_limitation)
      AddAssignedScopeLimitationService.call(@legal_aid_application, scope_limitation)
    end
  end

  private

  def proceeding_type(id)
    ProceedingType.find(id)
  end

  # def application_proceeding_types
  #   @application_proceeding_types ||= @legal_aid_application.application_proceeding_types
  #   # puts "first assigned proceeding type below"
  #   # pp @assigned_proceeding_types.first
  # end
end
