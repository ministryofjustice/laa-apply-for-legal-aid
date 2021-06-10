module LegalFramework
  class ProceedingTypesService
    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def add(proceeding_type_id: nil, scope_type: nil)
      return false unless proceeding_type_id && scope_type

      ActiveRecord::Base.transaction do
        @legal_aid_application.reset_proceeding_types! unless Setting.allow_multiple_proceedings? # This will probably change when multiple proceeding types implemented!
        @legal_aid_application.proceeding_types << proceeding_type(proceeding_type_id)
        LeadProceedingAssignmentService.call(@legal_aid_application)
        AddAssignedScopeLimitationService.call(@legal_aid_application, proceeding_type_id, scope_type)
      end
    end

    private

    def proceeding_type(id)
      ProceedingType.find(id)
    end
  end
end
