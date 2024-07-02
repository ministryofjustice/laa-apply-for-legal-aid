module Flow
  module Steps
    module ProviderMerits
      MeritsTaskListsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_merits_task_list_path(application) },
        forward: ->(application) { application.evidence_is_required? ? :uploaded_evidence_collections : :check_merits_answers },
      )
    end
  end
end
