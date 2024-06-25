module Flow
  module Steps
    module ProviderStart
      ProceedingsTypesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_proceedings_types_path(application) },
        forward: lambda do |_application, proceeding|
          case proceeding.sca_type
          when "core"
            :proceedings_sca_proceeding_issue_statuses
          when "related"
            :proceedings_sca_heard_togethers
          else
            :has_other_proceedings
          end
        end,
      )
    end
  end
end
