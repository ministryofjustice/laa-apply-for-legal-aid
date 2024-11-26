module Flow
  module Steps
    module ProviderStart
      PROHIBITED_STEPS_OR_SPECIFIC_ISSUE_REGEXP = /^SE00[3478](.*)\z/

      ProceedingsTypesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_proceedings_types_path(application) },
        forward: lambda do |_application, proceeding|
          if proceeding.sca_type == "core"
            :proceedings_sca_proceeding_issue_statuses
          elsif proceeding.sca_type == "related"
            :proceedings_sca_heard_togethers
          elsif PROHIBITED_STEPS_OR_SPECIFIC_ISSUE_REGEXP.match?(proceeding.ccms_code)
            :proceedings_sca_change_of_names
          else
            :has_other_proceedings
          end
        end,
      )
    end
  end
end
