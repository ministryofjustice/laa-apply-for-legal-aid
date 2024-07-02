module Flow
  module Steps
    module ProceedingsSCA
      ProceedingIssueStatusesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_proceeding_issue_statuses_path(application) },
        forward: lambda do |_application, proceeding|
          case proceeding.ccms_code
          when "PB006"
            :proceedings_sca_child_subjects
          when "PB059"
            :proceedings_sca_supervision_orders
          else
            :has_other_proceedings
          end
        end,
      )
    end
  end
end
