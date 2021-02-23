module LegalFramework
  class AddAssignedScopeLimitationService
    def initialize(legal_aid_application, proceeding_type_id, scope_type)
      @legal_aid_application = legal_aid_application
      @application_proceeding_type = @legal_aid_application.application_proceeding_types.find_by(proceeding_type_id: proceeding_type_id)
      @scope_type = scope_type
    end

    def self.call(legal_aid_application, proceeding_type_id, scope_type)
      new(legal_aid_application, proceeding_type_id, scope_type).call
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
      @application_proceeding_type.add_default_substantive_scope_limitation
    end

    def add_default_delegated_functions_scope_limitations!
      @application_proceeding_type.add_default_delegated_functions_scope_limitation
    end
  end
end
