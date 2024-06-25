module LegalFramework
  class AddProceedingService
    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def call(params)
      return false unless params[:ccms_code]

      new_proceeding = nil
      @ccms_code = params[:ccms_code]

      ActiveRecord::Base.transaction do
        new_proceeding = Proceeding.create!(proceeding_attrs)
        LeadProceedingAssignmentService.call(@legal_aid_application)
      end
      new_proceeding
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
        sca_type: proceeding_type.sca_type,
      }
    end
  end
end
