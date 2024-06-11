module Flow
  module Steps
    module ProceedingsSCA
      ProceedingIssueStatusesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_proceeding_issue_statuses_path(application) },
        forward: lambda { |_application, proceeding_is_issued|
                   proceeding_is_issued ? :has_other_proceedings : :somewhere_else
                 },
      )
    end
  end
end
