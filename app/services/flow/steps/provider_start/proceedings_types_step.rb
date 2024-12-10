module Flow
  module Steps
    module ProviderStart
      PROHIBITED_STEPS_OR_SPECIFIC_ISSUE_REGEXP = /^SE00[3478](.*)\z/
      PUBLIC_LAW_FAMILY_PROCEEDING_REGEXP = /^PBM(16|17|18|19|20|21|22)[AE]?$/

      ProceedingsTypesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_proceedings_types_path(application) },
        forward: lambda do |_application, proceeding|
          if proceeding.sca_type == "core"
            :proceedings_sca_proceeding_issue_statuses
          elsif proceeding.sca_type == "related"
            :proceedings_sca_heard_togethers
          elsif PROHIBITED_STEPS_OR_SPECIFIC_ISSUE_REGEXP.match?(proceeding.ccms_code)
            :change_of_names
          elsif PUBLIC_LAW_FAMILY_PROCEEDING_REGEXP.match?(proceeding.ccms_code)
            :related_orders
          else
            :has_other_proceedings
          end
        end,
      )
    end
  end
end
