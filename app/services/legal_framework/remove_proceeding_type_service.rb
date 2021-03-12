module LegalFramework
  class RemoveProceedingTypeService
    def self.call(legal_aid_application, proceeding_type)
      new(legal_aid_application, proceeding_type).call
    end

    def initialize(legal_aid_application, proceeding_type)
      @legal_aid_application = legal_aid_application
      @proceeding_type = proceeding_type
      @application_proceeding_type = @legal_aid_application.application_proceeding_types.find_by(proceeding_type_id: proceeding_type.id)
    end

    def call
      @application_proceeding_type.application_proceeding_types_scope_limitations.each(&:destroy!)
      @application_proceeding_type.destroy!
    end
  end
end
