module LegalFramework
  class AddProceedingService
    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def call(params)
      return false unless params[:ccms_code]

      @ccms_code = params[:ccms_code]

      ActiveRecord::Base.transaction do
        default_attrs = proceeding_attrs
        attrs = Setting.enable_loop? ? default_attrs : default_attrs.merge(scope_limitation_attrs)
        p = Proceeding.create(attrs)
        add_scope_limitations(p)
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
        substantive_cost_limitation: proceeding_type.cost_limitations.dig("substantive", "value"),
        delegated_functions_cost_limitation: proceeding_type.cost_limitations.dig("delegated_functions", "value"),
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
        substantive_level_of_service: 3,
        substantive_level_of_service_name: "Full Representation",
        substantive_level_of_service_stage: 8,
        emergency_level_of_service: 3,
        emergency_level_of_service_name: "Full Representation",
        emergency_level_of_service_stage: 8,
      }
    end

    def add_scope_limitations(proceeding)
      return if Setting.enable_loop?

      proceeding.scope_limitations.create(scope_type: :substantive,
                                          code: proceeding_type.default_scope_limitations.dig("substantive", "code"),
                                          meaning: proceeding_type.default_scope_limitations.dig("substantive", "meaning"),
                                          description: proceeding_type.default_scope_limitations.dig("substantive", "description"))
      return if proceeding_type.default_scope_limitations.dig("delegated_functions", "code").blank?

      proceeding.scope_limitations.create(scope_type: :emergency,
                                          code: proceeding_type.default_scope_limitations.dig("delegated_functions", "code"),
                                          meaning: proceeding_type.default_scope_limitations.dig("delegated_functions", "meaning"),
                                          description: proceeding_type.default_scope_limitations.dig("delegated_functions", "description"))
    end
  end
end
