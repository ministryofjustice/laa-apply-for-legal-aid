module LegalFramework
  class AddProceedingService
    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def call(params)
      return false unless params[:ccms_code]

      @ccms_code = params[:ccms_code]

      ActiveRecord::Base.transaction do
        Proceeding.create(proceeding_attrs.merge(scope_limitation_attrs))
        LeadProceedingAssignmentService.call(@legal_aid_application)
      end
      true
    end

  private

    attr_reader :ccms_code

    def proceeding_type
      @proceeding_type ||= LegalFramework::ProceedingTypes::Proceeding.call(ccms_code)
    end

    def proceeding_attrs
      {
        legal_aid_application_id: @legal_aid_application.id,
        lead_proceeding: false,
        ccms_code: proceeding_type.ccms_code,
        meaning: proceeding_type.meaning,
        description: proceeding_type.description,
        substantive_cost_limitation: proceeding_type.cost_limitations.dig('substantive', 'value'),
        delegated_functions_cost_limitation: proceeding_type.cost_limitations.dig('delegated_functions', 'value'),
        used_delegated_functions_on: nil,
        used_delegated_functions_reported_on: nil,
        name: proceeding_type.name,
        matter_type: proceeding_type.ccms_matter,
        category_of_law: proceeding_type.ccms_category_law,
        category_law_code: proceeding_type.ccms_category_law_code,
        ccms_matter_code: proceeding_type.ccms_matter_code,
      }
    end

    def scope_limitation_attrs
      {
        substantive_scope_limitation_code: proceeding_type.default_scope_limitations.dig('substantive', 'code'),
        substantive_scope_limitation_meaning: proceeding_type.default_scope_limitations.dig('substantive', 'meaning'),
        substantive_scope_limitation_description: proceeding_type.default_scope_limitations.dig('substantive', 'description'),
        delegated_functions_scope_limitation_code: proceeding_type.default_scope_limitations.dig('delegated_functions', 'code'),
        delegated_functions_scope_limitation_meaning: proceeding_type.default_scope_limitations.dig('delegated_functions', 'meaning'),
        delegated_functions_scope_limitation_description: proceeding_type.default_scope_limitations.dig('delegated_functions', 'description'),
      }
    end
  end
end
