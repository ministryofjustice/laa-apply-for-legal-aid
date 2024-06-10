module Flow
  module Steps
    module ProceedingsSCA
      ProceedingIssueStatusesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_proceeding_issue_statuses_path(application) },
        forward: :has_other_proceedings,
      )
    end
  end
end
